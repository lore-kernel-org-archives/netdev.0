From: James Morris <jmorris@redhat.com>
Subject: Re: [RFC] SO_PEERSEC - security credentials for Unix stream sockets
Date: Tue, 16 Dec 2003 08:19:44 -0500 (EST)
Sender: linux-security-module-bounces@wirex.com
Message-ID: <Xine.LNX.4.44.0312160816350.16300-100000@thoron.boston.redhat.com>
References: <20031215173241.B14552@osdlab.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: "David S. Miller" <davem@redhat.com>, kuznet@ms2.inr.ac.ru,
	linux-security-module@wirex.com,
	Stephen Smalley <sds@epoch.ncsc.mil>, netdev@oss.sgi.com
Return-path: <linux-security-module-bounces@wirex.com>
To: Chris Wright <chrisw@osdl.org>
In-Reply-To: <20031215173241.B14552@osdlab.pdx.osdl.net>
List-Unsubscribe: <http://mail.wirex.com/mailman/listinfo/linux-security-module>,
	<mailto:linux-security-module-request@mail.wirex.com?subject=unsubscribe>
List-Archive: <http://mail.immunix.com/pipermail/linux-security-module>
List-Post: <mailto:linux-security-module@mail.wirex.com>
List-Help: <mailto:linux-security-module-request@mail.wirex.com?subject=help>
List-Subscribe: <http://mail.wirex.com/mailman/listinfo/linux-security-module>,
	<mailto:linux-security-module-request@mail.wirex.com?subject=subscribe>
Errors-To: linux-security-module-bounces@wirex.com
List-Id: netdev.vger.kernel.org

On Mon, 15 Dec 2003, Chris Wright wrote:

> * James Morris (jmorris@redhat.com) wrote:
> > I'm not sure how this would be a namespace issue -- do you mean a data 
> > format issue?
> 
> I just mean, applications are coded for specific security module.

Applications which are security aware (i.e. only a few of them) will need 
to know the semantics of the security model that they are interacting 
with, so I'm not sure that namespace is going to be the biggest challenge.  

A good way to handle this is to use external pluggable modules like PAM.

> 
> > Yep, allowing the security module to update the returned length is now
> > implemented.
> > 
> > > Perhaps buffer is too small, can len be vector for that info?
> > 
> > I would not advise updating len on error -- it's a bad idea in general to
> > interpret any returned data from failed syscalls except the error number.
> 
> Right, in some cases a NULL buffer or 0 buflen is a probe for size.

It's not reliable: the required buffer size could change between calls.  
Do you know of any examples of syscalls which do this?


- James
-- 
James Morris
<jmorris@redhat.com>
