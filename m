From: Vasiliy Kulikov <segoon@openwall.com>
Subject: module loading with CAP_NET_ADMIN
Date: Thu, 24 Feb 2011 18:12:38 +0300
Message-ID: <20110224151238.GA16916@albatros>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, Kees Cook <kees.cook@canonical.com>,
	Eugene Teo <eugene@redhat.com>,
	Dan Rosenberg <dan.j.rosenberg@gmail.com>,
	"David S. Miller" <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi netdev folks,

I'd like to discuss the ability to load any modules from /lib/modules/
by a process with CAP_NET_ADMIN.  Since Linux 2.6.32 [1] there is such
possibility:

root@albatros:~# grep Cap /proc/$$/status
CapInh: 0000000000000000
CapPrm: fffffffc00001000
CapEff: fffffffc00001000
CapBnd: fffffffc00001000
root@albatros:~# lsmod | grep xfs
root@albatros:~# ifconfig xfs
xfs: error fetching interface information: Device not found
root@albatros:~# lsmod | grep xfs
xfs                   767011  0 
exportfs                4226  2 xfs,nfsd

Ability of CAP_NET_ADMIN to load the driver to work with a particular
network device is rational;  however, one may load any module not even
related to network this way.  Hopefully, this is not equal to
CAP_SYS_MODULE since the module set is restricted to /lib/modules
(additionally may be disabled with /proc/sys/kernel/modules_disabled),
but the idea of non-netdev module loading is weird.

My proposal is changing request_module("%s", name) to something like
request_module("netdev-%s", name) inside of dev_load() and adding
aliases to related drivers.  This would allow to load only netdev
modules via these ioctls.  I'm not sure what modules should be patches -
at least real physical netdevices have names different from drivers'
names, so they don't need patching.  I suppose the list is not big.

Any comments are welcome.


[1] http://git.kernel.org/?p=linux/kernel/git/torvalds/linux-2.6.git;a=commit;h=a8f80e8ff94ecba629542d9b4b5f5a8ee3eb565c


Thanks,

-- 
Vasiliy Kulikov
http://www.openwall.com - bringing security into open computing environments
