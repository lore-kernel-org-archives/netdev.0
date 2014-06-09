From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2] bridge: Make filter_index match in signedness
Date: Mon, 9 Jun 2014 12:40:32 -0700
Message-ID: <20140609124032.4b3fdea9@nehalam.linuxnetplumber.net>
References: <1401903637-21398-1-git-send-email-andreas@fatal.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Andreas Henriksson <andreas@fatal.se>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f46.google.com ([209.85.160.46]:38371 "EHLO
	mail-pb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754111AbaFITsJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Jun 2014 15:48:09 -0400
Received: by mail-pb0-f46.google.com with SMTP id rq2so5314549pbb.19
        for <netdev@vger.kernel.org>; Mon, 09 Jun 2014 12:48:08 -0700 (PDT)
In-Reply-To: <1401903637-21398-1-git-send-email-andreas@fatal.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed,  4 Jun 2014 19:40:37 +0200
Andreas Henriksson <andreas@fatal.se> wrote:

> From the original report at http://bugs.debian.org/749155
> Michael Tautschnig wrote:
> 
> During a rebuild [...]. Please note that we use our research
> compiler tool-chain (using tools from the cbmc package), which permits extended
> reporting on type inconsistencies at link time.
> 
> [...]
> gcc   bridge.o fdb.o monitor.o link.o mdb.o vlan.o ../lib/libnetlink.a ../lib/libutil.a  ../lib/libnetlink.a ../lib/libutil.a -o bridge
> file link.c line 18: error: conflicting types for variable "filter_index"
> old definition in module fdb file fdb.c line 29
> signed int
> new definition in module link file link.c line 18
> unsigned int
> <builtin>: recipe for target 'bridge' failed
> make[3]: *** [bridge] Error 64
> make[3]: Leaving directory '/srv/jenkins-slave/workspace/sid-goto-cc-iproute2/iproute2-3.14.0/bridge'
> Makefile:45: recipe for target 'all' failed
> 
> While practical constraints may limit the value of filter_index to remain within
> the bounds of a positive signed int, there is certainly no such guarantee here.
> Also, a plain majority vote suggests that this really just a wrong declaration
> in link.c as several declarations of filter_index as signed int exist.
> 
> [...]
> 
> My followup on this was:
> 
> I think the majority is wrong.
> 
> filter_index is assigned exclusively from if_nametoindex or ll_name_to_index
> which both return unsigned int.
> 
> Changing it to unsigned everywhere seems better.
> 
> This has been minimally tested by using the bridge tool
> to add vids and showing available vids on different devices.
> 
> Reported-by: Michael Tautschnig <mt@debian.org>
> Signed-off-by: Andreas Henriksson <andreas@fatal.se>

Applied
