From: Al Boldi <a1426z@gawab.com>
Subject: Re: [PATCH][v2] Netfilter Kconfig: Expose IPv4/6 connection tracking options by selecting NF_CONNTRACK_ENABLED
Date: Thu, 26 Jul 2007 06:53:23 +0300
Message-ID: <200707260653.23527.a1426z@gawab.com>
References: <200707251802.22200.a1426z@gawab.com> <46A7EECD.9070801@trash.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: 7bit
Cc: netfilter-devel@lists.netfilter.org, netdev@vger.kernel.org,
	Sam Ravnborg <sam@ravnborg.org>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [212.12.190.146] ([212.12.190.146]:32820 "EHLO raad.intranet"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1757107AbXGZDyQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 25 Jul 2007 23:54:16 -0400
In-Reply-To: <46A7EECD.9070801@trash.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Patrick McHardy wrote:
> Al Boldi wrote:
> > Make NF_CONNTRACK_IPV4 and NF_CONNTRACK_IPV6 select
> > NF_CONNTRACK_ENABLED.
>
> One thought that occured to me after the last of many false bugreports
> that were actually caused by failure to configure the new options
> properly. Most people know they want NF_CONNTRACK (and its selected by
> default with old configs), what they're missing is that they now also
> need to select IPv4 connection tracking. So what would really make sense
> is to make NF_CONNTRACK_IPV4 default to "m" (and really *everyone*
> using conntrack wants this). But with your proposed change this would
> default to selecting NF_CONNTRACK by default, which I'm not so sure
> is a good idea.

Making NF_CONNTRACK_IPV4 default to "m" would select NF_CONNTRACK to "m" if 
it hasn't been selected by the user to be "y", which seems reasonable.

> So I'm leaning towards just using "m" as default for
> IPv4 conntrack to save people trouble and myself some bugreports, but
> I also like your simplification ...

I was also planning to submit another patch to make all netfilter 
childoptions options default to their parent, i.e: NF_CONNTRACK_FTP would 
default NF_CONNTRACK.  This could be one big Kconfig time-saver.

> Maybe we can do something to have the NF_CONNTRACK_ENABLED option select
> NF_CONNTRACK_IPV4 (which really is what we actually want) and combine
> that with automatic selection of NF_CONNTRACK? I believe the only case
> with negative impact would be people that currently use only IPv6
> connection tracking, which is most likely nobody.

I think that wouldn't be advisable, as this would add an unnecessary 
dependency.  But of course,  it's your call...


Thanks!

--
Al

