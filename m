From: Greg KH <gregkh@suse.de>
Subject: Re: [PATCH] sysfs: Make sysfs_rename safe with sysfs_dirents in
 rbtrees.
Date: Tue, 1 Nov 2011 14:19:15 -0700
Message-ID: <20111101211915.GA20290@suse.de>
References: <20111025.063206.2273357152859701628.davem@davemloft.net>
 <CA+55aFw1GVvszqoC_f0RAvG5t1xj0CSYLhLU=y0gQ+_54Gsomw@mail.gmail.com>
 <20111025131315.GA1899@suse.de>
 <4EAC8642.3050309@suse.cz>
 <m11utvytg4.fsf@fess.ebiederm.org>
 <4EADB864.3060702@suse.cz>
 <m1mxcgrl7q.fsf_-_@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
	Jiri Slaby <jirislaby@gmail.com>,
	David Miller <davem@davemloft.net>,
	Mikulas Patocka <mpatocka@redhat.com>,
	akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, Jiri Slaby <jslaby@suse.cz>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <m1mxcgrl7q.fsf_-_@fess.ebiederm.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Nov 01, 2011 at 07:06:17AM -0700, Eric W. Biederman wrote:
> 
> In sysfs_rename remove the optimization of not calling sysfs_unlink_sibling
> and sysfs_link_sibling if the renamed parent directory is not changing.
> This optimization is no longer valid now that sysfs dirents are stored in an
> rbtree sorted by name.
> 
> Move the assignment of s_ns before the call of sysfs_link_sibling.  With no
> sysfs_dirent fields changing after the call of sysfs_link_sibling this allows
> sysfs_link_sibling to take any of the directory entries into account when
> it builds the rbtrees, and s_ns looks like a prime canidate to be used
> in the rbtree in the future.
> 
> Signed-off-by: Eric W. Biederman <ebiederm@xmission.com>

Looks good, Linus, thanks for taking this in your tree already.

greg k-h
