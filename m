From: One Thousand Gnomes <gnomes@lxorguk.ukuu.org.uk>
Subject: /proc/net/ symlink interacts badly with threads (Re: Procfs race
 condition bug)
Date: Mon, 7 Jul 2014 14:41:55 +0100
Message-ID: <20140707144155.7bbcf246@alan.etchedpixels.co.uk>
References: <20140704101311.GA7020@glue.grepular.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Mike Cardwell <linux@lists.grepular.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20140704101311.GA7020@glue.grepular.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 4 Jul 2014 11:13:11 +0100
Mike Cardwell <linux@lists.grepular.com> wrote:

> I originally posted this two years ago (*) but received no response. I
> just had a look and the problem still exists on the 3.14 kernel I am
> currently running.
> 
> I *think* I've uncovered a race condition bug in procfs. If I attempt to

I don't think you have found a race condition.

/proc/net/tcp is a symbolic link to /proc/self/net/tcp

Your thread does an open of /proc/net/tcp, which is a symlink
to /proc/self/net/tcp. If your thread id matches your process id then all
will be as you expect, if not then all will be pear shaped.

As far as I can see the code is doing precisely what it should do. It's
just that the use of the symlink when namespaces were added produces some
rather odd effects. 

It's certainly a bug. It used to work, it's sensible it should work.

Added netdev

Alan
