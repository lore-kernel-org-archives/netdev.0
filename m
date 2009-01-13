From: Denys Fedoryschenko <denys@visp.net.lb>
Subject: Re: [BUG #12364] Re: HTB - very bad precision? HFSC works =?iso-8859-15?q?fine!=092=2E6=2E28?=
Date: Tue, 13 Jan 2009 12:08:09 +0200
Message-ID: <200901131208.09692.denys@visp.net.lb>
References: <1935.87.196.72.187.1231371721.squirrel@webmail.decimal.pt> <200901122201.19616.denys@visp.net.lb> <496C198A.4060502@trash.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: 7bit
Cc: Jesper Dangaard Brouer <hawk@diku.dk>,
	netdev <netdev@vger.kernel.org>, bugme-daemon@bugzilla.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hosting.visp.net.lb ([194.146.153.11]:47821 "EHLO
	hosting.visp.net.lb" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751032AbZAMKIR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Jan 2009 05:08:17 -0500
In-Reply-To: <496C198A.4060502@trash.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tuesday 13 January 2009 06:33:14 Patrick McHardy wrote:
>
> Its odd that HZ=1000 solved the problem despite HR timers being active.
> Are you sure they're actually enabled? You should see something like
> this in the ringbuffer:
>
> [    0.241972] Switched to high resolution mode on CPU 0
> [    0.242708] Switched to high resolution mode on CPU 1
> --
I had nmi_watchdog enabled, and kernel log was too short to check that 
message. But i think you are right, because of nmi_watchdog it was not in 
high resolution.

Plus my kernel is spammed by messages 
[  105.417236] UDP: bad checksum. From 58.137.24.102:33333 to 
213.254.233.11:42741 ulen 106
[  105.527209] UDP: bad checksum. From 200.7.99.22:33132 to 
213.254.233.11:61520 ulen 111
[  130.498537] UDP: bad checksum. From 210.213.100.122:33890 to 
213.254.233.10:64060 ulen 111
[  132.974111] UDP: bad checksum. From 189.144.209.72:2028 to 
213.254.233.11:1466 ulen 8259
[  133.499172] UDP: bad checksum. From 66.41.236.245:16496 to 
213.254.233.11:15055 ulen 71
[  140.826429] UDP: bad checksum. From 220.165.176.236:16001 to 
213.254.233.10:9422 ulen 297

Is net.core.warnings = 0 will remove them?
Their amount really annoying on router.

I will remove nmi_watchdog, apply Jarek patches to avoid crashes which i had 
before, and will check how much is precise shaper at peak time (after 9-10 
hours).  For now it will be 1000 HZ (not 100), 
