From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [patch net-next v3] tc: introduce OpenFlow classifier
Date: Sat, 11 Apr 2015 09:12:25 -0700
Message-ID: <20150411161223.GA802@Alexeis-MBP.westell.com>
References: <1428584287-8197-1-git-send-email-jiri@resnulli.us>
 <20150409.173423.2258417584616634411.davem@davemloft.net>
 <20150410091203.GA2021@nanopsycho.orion>
 <20150410.082359.964457460073432676.davem@davemloft.net>
 <20150410124517.GC2021@nanopsycho.orion>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	jhs@mojatatu.com, tgraf@suug.ch, jesse@nicira.com
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f173.google.com ([209.85.223.173]:36754 "EHLO
	mail-ie0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754231AbbDKQM1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 11 Apr 2015 12:12:27 -0400
Received: by iebrs15 with SMTP id rs15so38095258ieb.3
        for <netdev@vger.kernel.org>; Sat, 11 Apr 2015 09:12:26 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20150410124517.GC2021@nanopsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Apr 10, 2015 at 02:45:17PM +0200, Jiri Pirko wrote:
> Okay. That was misunderstanding. I was thinking about using existing
> flow_dissect. There are couple things which I'm scared of:
> - there are eventually many fields to be added to dissection function and to
>   the structure as well. Not sure how acceptable that would be for
>   performance reasons when flow_dissect is used by different users...

I share the same concern. I think flow_dissect is too performance
critical to reuse by expanding 'struct flow_keys'.
I think it would be better to generalize ovs's key_extract() into
common piece of code that TC classifier and ovs datapath can use.
It uses kernel internal 'struct sw_flow_key' which we can tweak to
accommodate more users. It's already gigantic at 392 bytes, so
split and a bit of diet would help too.
