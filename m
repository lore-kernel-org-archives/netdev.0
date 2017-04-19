From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: [PATCH v4 net-next RFC] net: Generic XDP
Date: Wed, 19 Apr 2017 10:44:59 -0700
Message-ID: <58F7A21B.9060309@gmail.com>
References: <20170415005949.GB73685@ast-mbp.thefacebook.com>
 <20170418190535.GG4730@C02RW35GFVH8.dhcp.broadcom.net>
 <20170418.150708.1605529107204449972.davem@davemloft.net>
 <20170418.152916.1361453741909754079.davem@davemloft.net>
 <20170419142903.GJ4730@C02RW35GFVH8.dhcp.broadcom.net>
 <20170419171753.GA12838@ast-mbp.thefacebook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, michael.chan@broadcom.com,
        netdev@vger.kernel.org, xdp-newbies@vger.kernel.org
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>,
        Andy Gospodarek <andy@greyhouse.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f196.google.com ([209.85.223.196]:34637 "EHLO
        mail-io0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S968618AbdDSRpV (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 19 Apr 2017 13:45:21 -0400
In-Reply-To: <20170419171753.GA12838@ast-mbp.thefacebook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 17-04-19 10:17 AM, Alexei Starovoitov wrote:
> On Wed, Apr 19, 2017 at 10:29:03AM -0400, Andy Gospodarek wrote:
>>
>> I ran this on top of a card that uses the bnxt_en driver on a desktop
>> class system with an i7-6700 CPU @ 3.40GHz, sending a single stream of
>> UDP traffic with flow control disabled and saw the following (all stats
>> in Million PPS).
>>
>>                 xdp1                xdp2            xdp_tx_tunnel
>> Generic XDP      7.8    5.5 (1.3 actual)         4.6 (1.1 actual)
>> Optimized XDP   11.7		     9.7                      4.6
> 
> Nice! Thanks for testing.
> 
>> One thing to note is that the Generic XDP case shows some different
>> results for reported by the application vs actual (seen on the wire).  I
>> did not debug where the drops are happening and what counter needs to be
>> incremented to note this -- I'll add that to my TODO list.  The
>> Optimized XDP case does not have a difference in reported vs actual
>> frames on the wire.
> 
> The missed packets are probably due to xmit queue being full.
> We need 'xdp_tx_full' counter in:
> +       if (free_skb) {
> +               trace_xdp_exception(dev, xdp_prog, XDP_TX);
> +               kfree_skb(skb);
> +       }
> like in-driver xdp does.
> It's surprising that tx becomes full so often. May be bnxt specific behavior?

hmm as a data point I get better numbers than 1.3Mpps running through the qdisc
layer with pktgen so seems like something is wrong with the driver perhaps? If
I get a chance I'll take a look with my setup here, although it likely wont be
until the weekend. I don't think it needs to slow down dropping the RFC tag
and getting the patch applied though.

> 
>> I agree with all those who have asserted that this is great tool for
>> those that want to get started with XDP but do not have hardware, so I'd
>> say it's ready to have the 'RFC' tag dropped.  Thanks for pushing this
>> forward, Dave!  :-)
> 
> +1
>  
> 
