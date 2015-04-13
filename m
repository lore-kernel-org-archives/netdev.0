From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [patch net-next v3] tc: introduce OpenFlow classifier
Date: Mon, 13 Apr 2015 16:34:44 +0200
Message-ID: <20150413143444.GE2090@nanopsycho.lan>
References: <20150412075351.GA2112@nanopsycho.orion>
 <20150412.194443.1571071793033525091.davem@davemloft.net>
 <20150413001212.GA1656@Alexeis-MBP.westell.com>
 <20150412.203618.86474109049619893.davem@davemloft.net>
 <20150413010342.GA1672@Alexeis-MBP.westell.com>
 <20150413082600.GA16323@casper.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Alexei Starovoitov <alexei.starovoitov@gmail.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	jhs@mojatatu.com, jesse@nicira.com
To: Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f178.google.com ([209.85.212.178]:35922 "EHLO
	mail-wi0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753875AbbDMOes (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Apr 2015 10:34:48 -0400
Received: by wizk4 with SMTP id k4so75302850wiz.1
        for <netdev@vger.kernel.org>; Mon, 13 Apr 2015 07:34:47 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20150413082600.GA16323@casper.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Mon, Apr 13, 2015 at 10:26:00AM CEST, tgraf@suug.ch wrote:
>On 04/12/15 at 06:03pm, Alexei Starovoitov wrote:
>> On Sun, Apr 12, 2015 at 08:36:18PM -0400, David Miller wrote:
>> > 
>> > It's easy to parameterize what flow dissector does and share code.
>> 
>> yes. Though I wouldn't pessimize ixgbe rx path even by single
>> cycle to accommodate openflow spec. As far as I understand the
>> skb_flow_dissect() job from driver point of view is to figure
>> out header length for copybreak, which includes parsing encaps,
>> whereas openflow stops at outer header. Even with this difference,
>> it surely can be parameterized. Would be great to share if it
>> doesn't cost rx anything.
>
>A flow dissector that only extracts what's needed would benefit
>everyone. I guess static keys could help here as the flow field
>selection is definitely a slow path operation.

Hmm. Ok. I'll try to cook some patch in order to extend
skb_flow_dissect. Stay tuned.


>
>Even OVS could benefit from this eventually, it would just need
>to do a full extract before the key is sent to user space.
>
>Also, the logic to generate the wildcard mask and match on it
>should be generalized as well.
