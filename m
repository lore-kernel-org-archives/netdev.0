From: Gerd Hoffmann <kraxel@redhat.com>
Subject: Re: [PATCH 0/1] VM Sockets for Linux upstreaming
Date: Tue, 05 Feb 2013 17:41:27 +0100
Message-ID: <51113637.7070209@redhat.com>
References: <1360020362-25561-1-git-send-email-acking@vmware.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: pv-drivers@vmware.com, netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	virtualization@lists.linux-foundation.org,
	gregkh@linuxfoundation.org, davem@davemloft.net
To: Andy King <acking@vmware.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <1360020362-25561-1-git-send-email-acking@vmware.com>
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

  Hi,

> Unlike previous submissions, where the new socket family was entirely reliant
> on VMware's VMCI PCI device (and thus VMware's hypervisor), VM Sockets is now
> *completely* separated out into two parts, each in its own module:

Some separation still needs to be done:

  CC [M]  net/vmw_vsock/af_vsock.o
In file included from
/home/kraxel/projects/linux/net/vmw_vsock/af_vsock.c:102:0:
/home/kraxel/projects/linux/net/vmw_vsock/af_vsock.h:21:33: fatal error:
linux/vmw_vmci_defs.h: No such file or directory
compilation terminated.
make[4]: *** [net/vmw_vsock/af_vsock.o] Error 1

[ with  vmci series from jan 9th applied on top it builds ]

Module deps are a bit bogous too:

vmw_vsock_vmci_transport    26162  0
vsock                  34481  1 vmw_vsock_vmci_transport
vmw_vmci               61602  2 vsock,vmw_vsock_vmci_transport

Only vmw_vsock_vmci_transport should have a vmw_vmci dependency, not
vsock ...

Nevertheless this should be good enough to start hacking up a virtio
prototype.

cheers,
  Gerd
