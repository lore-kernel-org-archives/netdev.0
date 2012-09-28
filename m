From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next 3/3] ipv4: gre: add GRO capability
Date: Fri, 28 Sep 2012 16:04:01 +0200
Message-ID: <1348841041.5093.2477.camel@edumazet-glaptop>
References: <1348750130.5093.1227.camel@edumazet-glaptop>
	 <CAEP_g=-JAYHXM86AYNp7BhDV+eqfkKVgC+SJS1MVdo0K8fRLSQ@mail.gmail.com>
	 <1348769294.5093.1566.camel@edumazet-glaptop>
	 <1348769990.5093.1584.camel@edumazet-glaptop>
	 <CAEP_g=8B7xZPxye0Kuu-EVKpTDt1a3nsJKb61aaYaqOGsYGx8w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Jesse Gross <jesse@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:64455 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756714Ab2I1OEG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Sep 2012 10:04:06 -0400
Received: by bkcjk13 with SMTP id jk13so3430739bkc.19
        for <netdev@vger.kernel.org>; Fri, 28 Sep 2012 07:04:04 -0700 (PDT)
In-Reply-To: <CAEP_g=8B7xZPxye0Kuu-EVKpTDt1a3nsJKb61aaYaqOGsYGx8w@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2012-09-27 at 15:03 -0700, Jesse Gross wrote:

> We wouldn't actually do the decapsulation at the point of GRO.  This
> is actually pretty similar to what we do with TCP - we merge TCP
> payloads even though we haven't done any real IP processing yet.
> However, we do check firewall rules later if we actually hit the IP
> stack.  GRE would work the same way in this case.
> 
> What I'm describing is pretty much exactly what NICs will be doing, so
> if that doesn't work we'll have a problem...

GRO ability to truly aggregate data is kind of limited to some
workloads. How NICs will handle interleaved flows I dont really know.

What you describe needs a serious GRO preliminary work, because it
depends on napi_gro_flush() being called from time to time, while we
need something else, more fine grained.

(I am pretty sure GRO needs some love from us, it looks like some
packets can stay a long time in gro_list. It would be nice if it was
able to reorder packets (from same flow) as well)

Anyway, my changes are self-contained in a new file and non intrusive.

As soon as we can provide a better alternative we can revert them ?

Thanks
