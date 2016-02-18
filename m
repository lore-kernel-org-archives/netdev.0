From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2] netns: Fix an off-by-one strcpy() in
 netns_map_add().
Date: Wed, 17 Feb 2016 17:55:09 -0800
Message-ID: <20160217175509.4073210d@xeon-e3>
References: <1455284859-31210-1-git-send-email-nicolas.cavallari@green-communications.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Nicolas Cavallari <nicolas.cavallari@green-communications.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f179.google.com ([209.85.192.179]:33771 "EHLO
	mail-pf0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1422931AbcBRBy7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Feb 2016 20:54:59 -0500
Received: by mail-pf0-f179.google.com with SMTP id q63so21624795pfb.0
        for <netdev@vger.kernel.org>; Wed, 17 Feb 2016 17:54:59 -0800 (PST)
In-Reply-To: <1455284859-31210-1-git-send-email-nicolas.cavallari@green-communications.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 12 Feb 2016 14:47:39 +0100
Nicolas Cavallari <nicolas.cavallari@green-communications.fr> wrote:

> netns_map_add() does a malloc of (sizeof (struct nsid_cache) +
> strlen(name)) and then proceed with strcpy() of name into the
> zero-length member at the end of the nsid_cache structure.  The
> nul-terminator is written outside of the allocated memory and may
> overwrite the allocator's internal structure.
> 
> This can trigger a segmentation fault on i386 uclibc with names of size 8:
> after the corruption occurs, the call to closedir() on netns_map_init()
> crashes while freeing the DIR structure.
> 
> Here is the relevant valgrind output:
> 
> ==1251== Memcheck, a memory error detector
> ==1251== Copyright (C) 2002-2015, and GNU GPL'd, by Julian Seward et al.
> ==1251== Using Valgrind-3.11.0 and LibVEX; rerun with -h for copyright
> info
> ==1251== Command: ./ip netns
> ==1251==
> ==1251== Invalid write of size 1
> ==1251==    at 0x4011975: strcpy (in
> /usr/lib/valgrind/vgpreload_memcheck-x86-linux.so)
> ==1251==    by 0x8058B00: netns_map_add (ipnetns.c:181)
> ==1251==    by 0x8058E2A: netns_map_init (ipnetns.c:226)
> ==1251==    by 0x8058E79: do_netns (ipnetns.c:776)
> ==1251==    by 0x804D9FF: do_cmd (ip.c:110)
> ==1251==    by 0x804D814: main (ip.c:300)

Applied, thanks.
