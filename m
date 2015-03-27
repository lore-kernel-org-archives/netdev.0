From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [patch net-next] tc: introduce OpenFlow classifier
Date: Fri, 27 Mar 2015 13:45:13 +0100
Message-ID: <20150327124513.GB2172@nanopsycho.orion>
References: <1427374439-11587-1-git-send-email-jiri@resnulli.us>
 <1427379836.29436.9.camel@stressinduktion.org>
 <20150326152938.GD2010@nanopsycho.orion>
 <1427402351.2093330.245738573.1406B9EA@webmail.messagingengine.com>
 <20150327060716.GB2073@nanopsycho.orion>
 <20150327114402.GB12265@casper.infradead.org>
 <20150327122846.GA2172@nanopsycho.orion>
 <20150327123627.GG12265@casper.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>,
	netdev@vger.kernel.org, davem@davemloft.net, jhs@mojatatu.com,
	jesse@nicira.com
To: Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f45.google.com ([74.125.82.45]:33696 "EHLO
	mail-wg0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752226AbbC0MpR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Mar 2015 08:45:17 -0400
Received: by wgbgs4 with SMTP id gs4so6965660wgb.0
        for <netdev@vger.kernel.org>; Fri, 27 Mar 2015 05:45:16 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20150327123627.GG12265@casper.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fri, Mar 27, 2015 at 01:36:27PM CET, tgraf@suug.ch wrote:
>On 03/27/15 at 01:28pm, Jiri Pirko wrote:
>> Fri, Mar 27, 2015 at 12:44:02PM CET, tgraf@suug.ch wrote:
>> >On 03/27/15 at 07:07am, Jiri Pirko wrote:
>> >> well, you can do *everything* with cls_bpf now that it supports ebpf.
>> >> But I think it is a big hammer. cls_openflow suppose to be just
>> >> replacement for existing ovs classification, with very simple and well
>> >> understood uapi.
>> >
>> >The current linear filtering approach makes it not suitable
>> >right now. No doubt that unifying flow classification would
>> >be great to have.
>> >
>> >Once you start building some form of wildcarded hash tables
>> >into this, I see a lot of overlap with cls_flow appearing.
>> >What about extending cls_flow instead? Are you still planning
>> >to have one cls_classifier instance per wildcard flow?
>> 
>> I'm not fan of extending cls_flow. It does something else. It calculates
>> hash and set classid according to that. I like better to do cls_openflow
>> on side.
>
>You'll probably end up with a hash as well. I doubt that you
>want to walk through a linear list of matches in the long term.
>Not sure about your plans though.

Sure, that was supposed next step, to change this to hash list.

>
>> >I'm usually all for small steps and take it from there but you
>> >are setting a uapi in stone here and once you add linear
>> >filtering behaviour you can't just undo it without a ton of
>> >flags.
>> 
>> 
>> Sure, what exactly is your uapi change proposal? I'd be glad to
>> incorporate it.
>
>You are adding linear matching with first-add-first-match
>behaviour. You can't break this order guarantee afterwards.

Allright.  I'll reimplement that.
