From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2 master] bpf: unbreak libelf linkage for bpf obj
 loader
Date: Wed, 9 Aug 2017 17:35:12 -0700
Message-ID: <20170809173512.2db1eb40@xeon-e3>
References: <8ddcce8a9564e9c4a265db790002d6cd5ba8f353.1502316870.git.daniel@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f179.google.com ([209.85.192.179]:35232 "EHLO
        mail-pf0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752330AbdHJAfP (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 9 Aug 2017 20:35:15 -0400
Received: by mail-pf0-f179.google.com with SMTP id t86so34220129pfe.2
        for <netdev@vger.kernel.org>; Wed, 09 Aug 2017 17:35:15 -0700 (PDT)
In-Reply-To: <8ddcce8a9564e9c4a265db790002d6cd5ba8f353.1502316870.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 10 Aug 2017 00:15:41 +0200
Daniel Borkmann <daniel@iogearbox.net> wrote:

> Commit 69fed534a533 ("change how Config is used in Makefile's") moved
> HAVE_MNL specific CFLAGS/LDLIBS for building with libmnl out of the
> top level Makefile into sub-Makefiles. However, it also removed the
> HAVE_ELF specific CFLAGS/LDLIBS entirely, which breaks the BPF object
> loader for tc and ip with "No ELF library support compiled in." despite
> having libelf detected in configure script. Fix it similarly as in
> 69fed534a533 for HAVE_ELF.
> 
> Fixes: 69fed534a533 ("change how Config is used in Makefile's")
> Reported-by: Jeffrey Panneman <jeffrey.panneman@tno.nl>
> Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>

Thanks, but I am thinking maybe a better solution long term would be to
move all the package specific stuff into the generated Config file.

That way only the generation shell script would have to change.

Also, all the flags should probably be using pkg-config to get the values.
