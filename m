From: hejianet <hejianet@gmail.com>
Subject: Re: [PATCH v5 0/7] Reduce cache miss for snmp_fold_field
Date: Wed, 28 Sep 2016 21:45:32 +0800
Message-ID: <c44daa11-dc57-84fa-35cc-40ee0fe293f3@gmail.com>
References: <1475043748-18161-1-git-send-email-hejianet@gmail.com>
 <20160928.050817.110671274247345232.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-sctp@vger.kernel.org,
        linux-kernel@vger.kernel.org, kuznet@ms2.inr.ac.ru,
        jmorris@namei.org, yoshfuji@linux-ipv6.org, kaber@trash.net,
        vyasevich@gmail.com, nhorman@tuxdriver.com,
        steffen.klassert@secunet.com, herbert@gondor.apana.org.au,
        marcelo.leitner@gmail.com
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160928.050817.110671274247345232.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On 9/28/16 5:08 PM, David Miller wrote:
> From: Jia He <hejianet@gmail.com>
> Date: Wed, 28 Sep 2016 14:22:21 +0800
>
>> v5:
>> - order local variables from longest to shortest line
> I still see many cases where this problem still exists.  Please
> do not resubmit this patch series until you fix all of them.
>
> Patch #2:
>
> -static int snmp_seq_show(struct seq_file *seq, void *v)
> +static int snmp_seq_show_ipstats(struct seq_file *seq, void *v)
>   {
>   	int i;
> +	u64 buff64[IPSTATS_MIB_MAX];
>   	struct net *net = seq->private;
>
> The order should be "net" then "buff64" then "i".
Sorry for my bad eyesight and quick hand :(
B.R.
Jia
>
> +static int snmp_seq_show_tcp_udp(struct seq_file *seq, void *v)
> +{
> +	int i;
> +	struct net *net = seq->private;
> +	unsigned long buff[TCPUDP_MIB_MAX];
>
> The order should be "buff", "net", then "i".
>
> Patch #3:
>
> @@ -192,13 +197,19 @@ static void snmp6_seq_show_item(struct seq_file *seq, void __percpu *pcpumib,
>   				const struct snmp_mib *itemlist)
>   {
>   	int i;
> -	unsigned long val;
> -
>   ...
> +	unsigned long buff[SNMP_MIB_MAX];
>
> The order should be "buff" then "i".
>
> @@ -206,10 +217,13 @@ static void snmp6_seq_show_item64(struct seq_file *seq, void __percpu *mib,
>   				  const struct snmp_mib *itemlist, size_t syncpoff)
>   {
>   	int i;
> +	u64 buff64[SNMP_MIB_MAX];
>
> Likewise.
>
> I cannot be any more explicit in my request than this.
>
