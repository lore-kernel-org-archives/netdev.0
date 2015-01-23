From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [patch net-next RFC] tc: introduce OpenFlow classifier
Date: Fri, 23 Jan 2015 09:43:13 -0800
Message-ID: <CAADnVQJLt7_oDNwaiQq6aYXMygVS9XD7QgJQ4srPpeW99QkmUg@mail.gmail.com>
References: <1421933824-17916-1-git-send-email-jiri@resnulli.us>
 <20150123151145.GK25797@casper.infradead.org> <20150123153842.GI2065@nanopsycho.orion>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Thomas Graf <tgraf@suug.ch>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Jamal Hadi Salim <jhs@mojatatu.com>
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f170.google.com ([209.85.216.170]:52984 "EHLO
	mail-qc0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751503AbbAWRne (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Jan 2015 12:43:34 -0500
Received: by mail-qc0-f170.google.com with SMTP id p6so7440256qcv.1
        for <netdev@vger.kernel.org>; Fri, 23 Jan 2015 09:43:34 -0800 (PST)
In-Reply-To: <20150123153842.GI2065@nanopsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jan 23, 2015 at 7:38 AM, Jiri Pirko <jiri@resnulli.us> wrote:
>>
>>If I understand skb_flow_dissect() correctly then you will always
>>fill of_flow_key with the inner most header. How would you for
>>example match on the outer UDP header?
>
> Yes, flow dissect is not ideal for this usage, for example also for the
> ipv6 addresses hashing. I was thinking about extending it. Eventually,
> this code can be merged with ovs as well.

if 'merging this with ovs' is the final goal then it's better
to do the other way around: extract ovs datapath and use it
as tc classifier.
Otherwise you'll essentially be repeating the same mistakes and
learning the same lessons as ovs guys did over years.
Especially considering the work we've been doing on ovs+bpf
it would be great to have common packet processing core
that is used by ovs and by tc.
ovs netlink interfaces will be all preserved and tc will gain
very capable datapath.
Obviously that is more involved than simply adding openflow-inspired
classifier, but imo it will be much more usable this way.
