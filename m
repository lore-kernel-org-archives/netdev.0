From: "David S. Miller" <davem@redhat.com>
Subject: Re: [RFC] SO_PEERSEC - security credentials for Unix stream sockets
Date: Wed, 10 Dec 2003 14:56:52 -0800
Sender: linux-security-module-bounces@wirex.com
Message-ID: <20031210145652.66bda4c2.davem@redhat.com>
References: <Xine.LNX.4.44.0312101110010.27922-100000@thoron.boston.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, linux-security-module@wirex.com,
	sds@epoch.ncsc.mil, netdev@oss.sgi.com
Return-path: <linux-security-module-bounces@wirex.com>
To: James Morris <jmorris@redhat.com>
In-Reply-To: <Xine.LNX.4.44.0312101110010.27922-100000@thoron.boston.redhat.com>
List-Unsubscribe: <http://mail.wirex.com/mailman/listinfo/linux-security-module>,
	<mailto:linux-security-module-request@mail.wirex.com?subject=unsubscribe>
List-Archive: <http://mail.immunix.com/pipermail/linux-security-module>
List-Post: <mailto:linux-security-module@mail.wirex.com>
List-Help: <mailto:linux-security-module-request@mail.wirex.com?subject=help>
List-Subscribe: <http://mail.wirex.com/mailman/listinfo/linux-security-module>,
	<mailto:linux-security-module-request@mail.wirex.com?subject=subscribe>
Errors-To: linux-security-module-bounces@wirex.com
List-Id: netdev.vger.kernel.org

On Wed, 10 Dec 2003 11:33:53 -0500 (EST)
James Morris <jmorris@redhat.com> wrote:

> Three new LSM hooks have been implemented:
> 
> - socket_getpeersec() is the getsockopt interface.
> 
> - sk_alloc_security() and sk_free_security() facilitate the use of an
>   sk_security field, which is used to store the security credentials of 
>   the Unix peer.  We can't use an existing security field for this (e.g. 
>   inode), as we need the security credentials of the server's child 
>   socket.  This follows the same general scheme used for managing existing 
>   Unix peer credentials.
> 
> Comments?

I'm fine with this conceptually, although the earliest I could put
this into the tree is 2.6.1 although I have a hunch that I'll be
asked to defer something like this to 2.6.2, but who knows.

The one thing I don't like is the ifdef conditionalized member of
the sock struct.  We should move away from config variables changing
structure layouts.  Even a "void *sk_security;" would be better.
