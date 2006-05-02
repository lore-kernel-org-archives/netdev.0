From: Andi Kleen <ak@suse.de>
Subject: Re: Disabling "TCP Treason uncloaked"
Date: Tue, 2 May 2006 18:02:43 +0200
Message-ID: <200605021802.43301.ak@suse.de>
References: <44578691.4020402@corky.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns.suse.de ([195.135.220.2]:14263 "EHLO mx1.suse.de")
	by vger.kernel.org with ESMTP id S964905AbWEBQCz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 May 2006 12:02:55 -0400
To: Just Marc <marc@corky.net>
In-Reply-To: <44578691.4020402@corky.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tuesday 02 May 2006 18:19, Just Marc wrote:

> I thought that maybe it's time to either set TCP_DEBUG to 0 or 
> alternatively allow an admin to toggle the printing of this message 
> off/on?  On a few busy web servers running usually latest versions of 
> 2.6 I have this message displaying hundreds (if not more) times a day, 

You're talking to a lot of broken TCP clients then.

> completely clogging the kernel log and making it harder to see if there 
> are more interesting messages being printed.   TCP_DEBUG is being used 
> in one more place that may also not require it anymore and or have it 
> always enabled.

It's better to use run time switches for these kind of things.

> So, is it time to disable this print altogether? Is it time to allow an 
> admin to toggle printing of this thing off?

If it's disabled there should be probably a netstat counter for the condition instead.

It might be a reasonable simple beginner project for someone:

- Convert all NETDEBUGs/TCP_DEBUG to a single netdebug sysctl
- Then perhaps make a CONFIG to change its default: 0 or 1
- Add statistics counters for all of these conditions

-Andi
