From: Patrick McHardy <kaber@trash.net>
Subject: [ofa-general] Re: [PATCH 03/10] dev.c changes.
Date: Fri, 20 Jul 2007 13:55:37 +0200
Message-ID: <46A0A2B9.1050504@trash.net>
References: <OF316A971D.F3CBB5DC-ON6525731E.003F6683-6525731E.004131B7@in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: jagana@us.ibm.com, johnpol@2ka.mipt.ru, herbert@gondor.apana.org.au,
	gaagaan@gmail.com, Robert.Olsson@data.slu.se,
	kumarkr@linux.ibm.com, rdreier@cisco.com,
	peter.p.waskiewicz.jr@intel.com, hadi@cyberus.ca,
	mcarlson@broadcom.com, jeff@garzik.org,
	general@lists.openfabrics.org, mchan@broadcom.com, tgraf@suug.ch,
	netdev@vger.kernel.org, davem@davemloft.net, sri@us.ibm.com
To: Krishna Kumar2 <krkumar2@in.ibm.com>
Return-path: <general-bounces@lists.openfabrics.org>
In-Reply-To: <OF316A971D.F3CBB5DC-ON6525731E.003F6683-6525731E.004131B7@in.ibm.com>
List-Unsubscribe: <http://lists.openfabrics.org/cgi-bin/mailman/listinfo/general>,
	<mailto:general-request@lists.openfabrics.org?subject=unsubscribe>
List-Archive: <http://lists.openfabrics.org/pipermail/general>
List-Post: <mailto:general@lists.openfabrics.org>
List-Help: <mailto:general-request@lists.openfabrics.org?subject=help>
List-Subscribe: <http://lists.openfabrics.org/cgi-bin/mailman/listinfo/general>,
	<mailto:general-request@lists.openfabrics.org?subject=subscribe>
Sender: general-bounces@lists.openfabrics.org
Errors-To: general-bounces@lists.openfabrics.org
List-Id: netdev.vger.kernel.org

Krishna Kumar2 wrote:
> Patrick McHardy <kaber@trash.net> wrote on 07/20/2007 04:50:37 PM
>> Is there any downside in using batching with smaller queue sizes?
>>     
>
> I think there is, but as yet I don't have any data (and 16 is probably
> higher
> than reqd) to show it. If the queue size is very small (like 4), the extra
> processing to maintain this list may take more cycles than the performance
> gains for sending out few skbs, esp since most xmits will send out 1 skb
> and
> skb batching takes places less often (when tx lock fails or queue gets
> full).
>
> OTOH, there might be a gain to even send out 2 skbs, the problem is in
> doing
> the extra processing before xmit and not at the time of xmit.
>
> Does this sound OK ? If so, I will add the code to implement the TODO for
> tx_queue_len checking too.
>   

I can't really argue about the numbers, but it seems to me that only
devices which *usually* have a sufficient queue length will support
this, and anyone setting the queue length of a gbit device to <16 is
begging for trouble anyway. So it doesn't really seem worth to bloat
the code for handling an insane configuration as long as it doesn't
break.
