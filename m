From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] LSM networking: skb hooks for 2.5.42 (2/7)
Date: Tue, 15 Oct 2002 13:10:37 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20021015.131037.96602290.davem@redhat.com>
References: <20021015194545.GC15864@kroah.com>
	<20021015.124502.130514745.davem@redhat.com>
	<20021015201209.GE15864@kroah.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: becker@scyld.com, jmorris@intercode.com.au, kuznet@ms2.inr.ac.ru,
   netdev@oss.sgi.com, linux-security-module@wirex.com
Return-path: <netdev-bounce@oss.sgi.com>
To: greg@kroah.com
In-Reply-To: <20021015201209.GE15864@kroah.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

   From: Greg KH <greg@kroah.com>
   Date: Tue, 15 Oct 2002 13:12:09 -0700

   Those invocations also take up no measurable time :)
   
I simply don't care.  They take up space in my kernel.

   Yes, the size of the *.o files in the security directory can be shrunk a
   bit:
      text    data     bss     dec     hex filename
      6765     776       8    7549    1d7d built-in.o
      3280     392       4    3676     e5c capability.o
      1772     384       0    2156     86c dummy.o
      1713       0       4    1717     6b5 security.o
   
It's a whopping 32K on sparc64, and that is only counting
the security/*.o objects.

Have you added up the text taken up comparing having
the security_ops->foo() stuff there and having it removed
in the rest of the entire tree?

Have you considered the different register and stack
allocations and code generations differences that occur
because this nop function call invocation is there?

It is not FREE, it has overhead, and this is a fact.

I'm so surprised the embedded people aren't all over
this.  If I was an embedded person, CONFIG_SECURITY=n
would be one of the top things on my list.

   > You must allow the user to config this stuff out of their tree.
   
   No, I only think the network stuff should be allowed to be compiled
   away, not the other hooks (ipc and vfs).
   
I totally disagree, CONFIG_SECURITY=n is mandatory.

If you don't work on this change, then I will get someone
else to do it.

I will not even look at the networking LSM bits until
CONFIG_SECURITY=n is available.
