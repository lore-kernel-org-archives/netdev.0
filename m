From: Patrick McHardy <kaber@trash.net>
Subject: Re: [RFC] meta ematch
Date: Sun, 16 Jan 2005 17:32:32 +0100
Message-ID: <41EA9720.7070503@trash.net>
References: <20050106194102.GW26856@postel.suug.ch>	 <1105105511.1046.77.camel@jzny.localdomain>	 <20050108145457.GZ26856@postel.suug.ch>	 <1105363582.1041.162.camel@jzny.localdomain>	 <20050110211747.GA26856@postel.suug.ch>	 <1105394738.1085.63.camel@jzny.localdomain>	 <20050113174111.GP26856@postel.suug.ch> <41E6C3E5.2020908@trash.net>	 <20050113192047.GQ26856@postel.suug.ch> <41E71CC4.3020102@trash.net>	 <20050114151407.GR26856@postel.suug.ch> <1105891871.1097.647.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Thomas Graf <tgraf@suug.ch>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: hadi@cyberus.ca
In-Reply-To: <1105891871.1097.647.camel@jzny.localdomain>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

jamal wrote:

>>+static int meta_int_loadavg_2(struct sk_buff *skb, struct tcf_pkt_info *info,
>>+			      struct meta_value *v, struct meta_obj *dst)
>>+{
>>+	dst->value = fixed_loadavg(avenrun[2]);
>>+	return 0;
>>+}
>>
>
>Theres a lot of parameters not used at all in these calls .get calls. So
>far i have seen dst->value and some of the skb fields used. I apologize,
>I normally dont pick on these things - so if you have future plans for
>why you are passing those, keep them and ignore the comment.
>BTW, it would probably be useful to return some mnemonic instead of 0.
>
Returning 0 for success and negative error codes is perfectly fine as long
as you don't need any magic numbers (1, 2, ..).

>>+static inline int var_dev(struct net_device *dev, struct meta_obj *dst)
>>+{
>>+	if (unlikely(dev == NULL))
>>+		return -1;
>>+
>>+	dst->value = (unsigned long) dev->name;
>>+	dst->len = strlen(dev->name);
>>    
>>
>
>So if device dissapears ... what happens to the pointer?
>  
>
Devices don't disappear during packet processing.

>>+static int meta_int_compare(struct meta_obj *a, struct meta_obj *b)
>>+{
>>+	/* Let gcc optimize it, the unlikely is not really based on
>>+	 * some numbers but jump free code for missmatches seems
>>+	 * more logical.
>>+	 */
>>+	if (unlikely(a == b))
>>+		return 0;
>>+	else if (a < b)
>>+		return -1;
>>+	else
>>+		return 1;
>>+}
>>    
>>
>
>Would be very useful to return mnemonics for readability.
>  
>
Same as for above, everyone knows what to expect from a *_compare function.
Returning stuff like CMP_LT, CMP_BT, .. is just ugly.

Regards
Patrick
