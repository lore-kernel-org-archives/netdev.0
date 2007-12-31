From: "Torsten Kaiser" <just.for.lkml@googlemail.com>
Subject: Re: [PATCH] Force UNIX domain sockets to be built in
Date: Mon, 31 Dec 2007 16:55:57 +0100
Message-ID: <64bb37e0712310755k2446e67eq81d31cd476eb75e3@mail.gmail.com>
References: <alpine.LSU.0.999.0712311300020.3686@be1.lrz>
	 <20071231122419.GA13803@does.not.exist>
	 <alpine.LSU.0.999.0712311335210.3761@be1.lrz>
	 <20071231144255.GB13803@does.not.exist>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "Bodo Eggert" <7eggert@gmx.de>,
	"Jan Engelhardt" <jengelh@computergmbh.de>, devzero@web.de,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: "Adrian Bunk" <bunk@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from py-out-1112.google.com ([64.233.166.179]:54944 "EHLO
	py-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750944AbXLaPz5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 31 Dec 2007 10:55:57 -0500
Received: by py-out-1112.google.com with SMTP id u52so9074933pyb.10
        for <netdev@vger.kernel.org>; Mon, 31 Dec 2007 07:55:57 -0800 (PST)
In-Reply-To: <20071231144255.GB13803@does.not.exist>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Dec 31, 2007 3:42 PM, Adrian Bunk <bunk@kernel.org> wrote:
> With CONFIG_MODULES=y the 13 EXPORT_SYMBOL's that only exist for the
> theoretical possibility of CONIG_UNIX=m waste a few hundred bytes
> of memory.

One thing I always wondered about in this discussion about wasted
EXPORT_SYMBOL's:
Shouldn't it be possible to garbage collect these?

depmod already contains code to analyze all modules to create a
dependency tree. It should not be too difficult to extend it to create
a list of all symbols that really are used by the current modules.
Everything else could be stripped to save space.

The problem with that:
* out-of-tree modules would break if they don't get lucky to only use
the remaining symbol. I would not see this as a problem, if the help
text of the garbage-collect-option would contain a note like "don't
enable this if you want out-of-tree modules".
* if you later change your .config to include additional modules you
might need to rebuild vmlinux and reboot into the new kernel.
Currently you can probably build and load new modules without a
reboot. (for example: usb drivers)

Torsten
