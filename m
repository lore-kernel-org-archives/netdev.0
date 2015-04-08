From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH v2 net-next 2/2] tc: make ingress and egress qdiscs
 consistent
Date: Wed, 8 Apr 2015 15:34:15 +0200
Message-ID: <20150408133415.GD2057@nanopsycho.orion>
References: <5524B339.1070403@plumgrid.com>
 <5524E878.7070803@iogearbox.net>
 <20150408090520.GA2057@nanopsycho.orion>
 <552508E8.5050203@iogearbox.net>
 <55250D92.6030702@iogearbox.net>
 <55251556.4040900@mojatatu.com>
 <55251F9F.2050508@iogearbox.net>
 <55252611.3040109@mojatatu.com>
 <20150408131417.GA28656@casper.infradead.org>
 <55252CDD.8020503@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Thomas Graf <tgraf@suug.ch>, Jamal Hadi Salim <jhs@mojatatu.com>,
	Alexei Starovoitov <ast@plumgrid.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f182.google.com ([209.85.212.182]:38555 "EHLO
	mail-wi0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753562AbbDHNeS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Apr 2015 09:34:18 -0400
Received: by wiun10 with SMTP id n10so58611122wiu.1
        for <netdev@vger.kernel.org>; Wed, 08 Apr 2015 06:34:17 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <55252CDD.8020503@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Wed, Apr 08, 2015 at 03:27:57PM CEST, daniel@iogearbox.net wrote:
>On 04/08/2015 03:14 PM, Thomas Graf wrote:
>>On 04/08/15 at 08:58am, Jamal Hadi Salim wrote:
>>>On 04/08/15 08:31, Daniel Borkmann wrote:
>>>>That means the tc's cls_u32
>>>>sample selectors a la ip, ip6, udp, tcp, icmp don't work on ingress
>>>>either,so in u32 speak you would need to do that by hand, but that
>>>>doesn't work as you don't have the Ethernet type context available.
>>>>Am I missing something? :)
>>>
>>>u32 works fine. I am sure i have tests which run these on both
>>>in/egress.
>>
>>His point is that an u32 filter written for egress won't work at
>>ingress because the offsets are different. This has always been the
>>case and we can't break this behaviour either. I'm sure you have
>>these weird negative offset u32 egress filters in your repertoire
>>as well ;-)
>
>Okay, you can use negative offsets in cls_u32 to accomodate for
>that; so yeah, you'd need to implement your filter differently
>on ingress. That should also work on cls_bpf et al.

That is certainly doable. But is that what we want? I don't think so. I
would like to have the same for in/eg.
