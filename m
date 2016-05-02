From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2] tc: add bash-completion function
Date: Mon, 2 May 2016 15:14:14 -0700
Message-ID: <20160502151414.0c9c3e3a@xeon-e3>
References: <20160428165349.GB81443@ast-mbp.thefacebook.com>
	<1461918431-6518-1-git-send-email-quentin.monnet@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: alexei.starovoitov@gmail.com, hadi@mojatatu.com,
	netdev@vger.kernel.org, vincent.jardin@6wind.com
To: Quentin Monnet <quentin.monnet@6wind.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f179.google.com ([209.85.192.179]:36167 "EHLO
	mail-pf0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755173AbcEBWOA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 May 2016 18:14:00 -0400
Received: by mail-pf0-f179.google.com with SMTP id c189so931112pfb.3
        for <netdev@vger.kernel.org>; Mon, 02 May 2016 15:14:00 -0700 (PDT)
In-Reply-To: <1461918431-6518-1-git-send-email-quentin.monnet@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 29 Apr 2016 10:27:11 +0200
Quentin Monnet <quentin.monnet@6wind.com> wrote:

> Add function for command completion for tc in bash, and update Makefile
> to install it:
> 
> - Under /usr/share/bash-completion/completions/ (default).
> - Or under /etc/bash_completions.d/, which is the old directory for
>   bash-completion, if /usr/share/bash-completion/completions/ is not
>   found AND /etc/bash_completions.d/ exists already.
> 
> Inside iproute2 repository, the completion code is in a new
> `bash-completion` toplevel directory.
> 
> Signed-off-by: Quentin Monnet <quentin.monnet@6wind.com>

Rather than having an if statement in the install; lets follow how
other paths are handles.
 * default value should be what current distros use /usr/share
 * other distro's can override it with environment variable.

Something like:

Makefile:
PREFIX?=/usr
LIBDIR?=$(PREFIX)/lib
SBINDIR?=/sbin
CONFDIR?=/etc/iproute2
DATADIR?=$(PREFIX)/share
DOCDIR?=$(DATADIR)/doc/iproute2
MANDIR?=$(DATADIR)/man
ARPDDIR?=/var/lib/arpd
KERNEL_INCLUDE?=/usr/include
BASH_COMPDIR?=$(DATADIR)/bash-completion/completions/
