From: Mark Seaborn <mrs@mythic-beasts.com>
Subject: Re: [PATCH] Security: Add prctl(PR_{GET,SET}_NETWORK) interface.
Date: Thu, 17 Dec 2009 22:58:56 +0000 (GMT)
Message-ID: <20091217.225856.145758950057800056.mrs@deli>
References: <20091217012540.GA2609@heat>
	<fb69ef3c0912170906t291a37c4r6c4758ddc7dd300b@mail.gmail.com>
	<20091217171447.GJ9804@basil.fritz.box>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: michael@laptop.org, drepper@gmail.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	linux-security-module@vger.kernel.org, david@lang.hm,
	socketcan@hartkopp.net, alan@lxorguk.ukuu.org.uk,
	herbert@gondor.apana.org.au, Valdis.Kletnieks@vt.edu,
	bdonlan@gmail.com, zbr@ioremap.net, cscott@cscott.net,
	jmorris@namei.org, ebiederm@xmission.com, bernie@codewiz.org
To: andi@firstfloor.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1755156AbZLQXii@vger.kernel.org>
In-Reply-To: <20091217171447.GJ9804@basil.fritz.box>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Andi Kleen <andi@firstfloor.org> wrote:

> > This is not very good because in some situations it is useful to disable
> > connect() and bind() while still allowing ptracing of other processes.  For
> > example, Plash creates a new UID for each sandbox and it is possible to use
> > strace and gdb inside a sandbox.  Currently Plash is not able to block
> > network access or allow only limited network access.  If you treat ptrace()
> > this way we won't have the ability to use strace and gdb while limiting
> > network access.
> 
> No that's not what the hunk does. I first thought the same. But it actually
> just limits these processes from initiating ptracing themselves. You can still
> attach gdb/strace to them.

No, I specifically mean running gdb/strace *inside* the sandbox so
that sandboxed processes can initiate ptrace on other processes inside
the same sandbox.  At the moment you can create a Plash sandbox and
run strace inside it with a command like the following, and strace
will successfully ptrace the subprocess that it spawns:

pola-run -B -e strace echo foo

I wouldn't want this to stop working just because the "disable
networking" flag has been set for all processes in the sandbox.

In practice Plash would set "disable networking" for all sandboxed
processes and then selectively enable limited network access by
passing file descriptors into the sandboxed processes via a socket.


> Now I'm not sure if that's closing all holes, but at least I can't come
> up with any obvious ones currently. I think I would still prefer a more
> general security container in general.

Well, yeah, adding a boolean just for network access seems pretty ad-hoc.

It sets alarm bells ringing if "disable networking" also functions as
"disable initiating ptrace()".  Isn't there a way of doing the latter
independently?

Cheers,
Mark
