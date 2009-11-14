From: David Miller <davem@davemloft.net>
Subject: Re: [RFC PATCH] net: add dataref destructor to sk_buff
Date: Fri, 13 Nov 2009 19:09:54 -0800 (PST)
Message-ID: <20091113.190954.189642997.davem@davemloft.net>
References: <4AFE08EF.2030308@gmail.com>
	<20091114022103.GA19020@gondor.apana.org.au>
	<4AFE15AD.6000208@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, ghaskins@novell.com, mst@redhat.com,
	alacrityvm-devel@lists.sourceforge.net,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: gregory.haskins@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37008
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755465AbZKNDJi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Nov 2009 22:09:38 -0500
In-Reply-To: <4AFE15AD.6000208@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gregory Haskins <gregory.haskins@gmail.com>
Date: Fri, 13 Nov 2009 21:27:57 -0500

> Clearly there must be _some_ mechanism to synchronize (e.g.
> flush/barrier) though, right?  Otherwise, that interface would seem to
> be quite prone to races and would likely be unusable.   So what does
> said flush use to know when the buffer is free?

There is no such synchronization at all.

If some synchronization is required, it must be done at a higher
level.

For example, SAMBA can only use sendfile() to serve file contents when
the client holds an SMB "OP Lock" on the file.  Luckily, by default
pretty much all SMB client implementations hold the OP Lock on a file
even just to read it (this is so that self-modifying autoexec.bat
scripts work :-)

But frankly most sendfile() consumers don't care, and the only thing
that really matters is that the checksum on the final TCP packet that
goes out is correct, and since we require card checksums to sendfile()
without copying, that is taken care of transparently.
