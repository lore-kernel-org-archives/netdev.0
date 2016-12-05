From: Guillaume Nault <g.nault@alphalink.fr>
Subject: Re: commit : ppp: add rtnetlink device creation support - breaks
 netcf on my machine.
Date: Mon, 5 Dec 2016 18:53:20 +0100
Message-ID: <20161205175320.mbtswpmdjumfgh7y@alphalink.fr>
References: <32208f70-4165-e79b-89ee-543eefaf40ef@fnarfbargle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev <netdev@vger.kernel.org>
To: Brad Campbell <lists2009@fnarfbargle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from zimbra.alphalink.fr ([217.15.80.77]:48091 "EHLO
        zimbra.alphalink.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751100AbcLERxZ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 5 Dec 2016 12:53:25 -0500
Content-Disposition: inline
In-Reply-To: <32208f70-4165-e79b-89ee-543eefaf40ef@fnarfbargle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Dec 05, 2016 at 05:06:31PM +0800, Brad Campbell wrote:
> Machine is an old Debian (7.11) box with a recent compile of netcf. Any
> kernel later than 4.6.7 prevents ncftool from running if the ppp interface
> is up.
> 
> I'm using netcf-0.2.8, and this commit breaks it :
> 
> 96d934c70db6e1bc135600c57da1285eaf7efb26 is the first bad commit
> commit 96d934c70db6e1bc135600c57da1285eaf7efb26
> Author: Guillaume Nault <g.nault@alphalink.fr>
> Date:   Thu Apr 28 17:55:30 2016 +0200
> 
>     ppp: add rtnetlink device creation support
> 
> The issue is netcf dies if the ppp interface is up with the informative
> message "Failed to initialize netcf". No debug output. Enabling debugging in
> libnl shows it dies when the data for the ppp interface is returned.
> 
> Take ppp down and ncftool comes up ok.
> 
> libnl appears to be version 3.2.24 (Debian libnl-3)
> 
> This has been manifesting on a production machine with a pppoe link to the
> world, but I managed to reproduce it on a test box using a pppoe server and
> a client on the test box which enabled me to bisect it.
> 
Can you send a minimal configuration file that triggers the bug?
I've set up a virtual machine (Linux 4.7.0, netcf 0.2.8 backported from
Debian Sid), but couldn't reproduce the issue so far.

> I don't know anything about netlink, nor the networking subsystem so I'm
> asking for a belt with a cluebat please. I'm using the latest *released*
> netcf, and a quick check of the git tree does not seem to indicate anything
> that might be related. Have I missed a kernel config option, or made some
> catastrophic blunder in setting this up? It works fine on 4.6.4, but
> anything 4.7 or later just dies if the ppp interface is up.
> 
Probably not a mistake on your side. I've started looking at netcf'
source code, but haven't found anything that could explain your issue.
It'd really help if you could provide steps to reproduce the bug.

Regards,

Guillaume
