From: Andy King <acking@vmware.com>
Subject: Re: [Pv-drivers] [PATCH 0/1] VM Sockets for Linux upstreaming
Date: Wed, 6 Feb 2013 16:32:30 -0800 (PST)
Message-ID: <1231523602.1815949.1360197150398.JavaMail.root@vmware.com>
References: <1315741351.2964541.1360083749055.JavaMail.root@vmware.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: pv-drivers@vmware.com, netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	virtualization@lists.linux-foundation.org,
	gregkh@linuxfoundation.org, davem@davemloft.net
To: Gerd Hoffmann <kraxel@redhat.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <1315741351.2964541.1360083749055.JavaMail.root@vmware.com>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/virtualization/>
List-Post: <mailto:virtualization@lists.linux-foundation.org>
List-Help: <mailto:virtualization-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=subscribe>
Sender: virtualization-bounces@lists.linux-foundation.org
Errors-To: virtualization-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

Hi Gerd,

> > linux/vmw_vmci_defs.h: No such file or directory
> > compilation terminated.
> > make[4]: *** [net/vmw_vsock/af_vsock.o] Error 1
> 
> Oops, you're right, it really shouldn't need that header.  Sorry
> about that, let me rip that out.

Fixed.  The VMCI headers are now gone from the core in af_vsock.*
and vsock_addr.*

> > Only vmw_vsock_vmci_transport should have a vmw_vmci dependency,
> > not vsock ...
> 
> Agreed, that's not right, I'll fix that too.

Fixed, lsmod now shows that only the transport has a dependency.

Also, it turns out that we do need a dgram_recv(), since our
transport currently enqueues skbs with VMCI DGRAMs in them, which
need to be converted before copying into the user's buffer.  I've
added that too.

Please see latest patchset (sent a few minutes ago), hope it works
for you this time.

Thanks!
- Andy
