From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: [PATCH 2.6.12-rc2 0/17] bonding: sysfs interface...
Date: Thu, 07 Apr 2005 17:41:15 -0700
Message-ID: <200504080041.j380fFAM004902@death.nxdomain.ibm.com>
References: <shemminger@osdl.org>
Cc: Radheka Godse <radheka.godse@intel.com>,
        bonding-devel@lists.sourceforge.net, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: Message from Stephen Hemminger <shemminger@osdl.org>
   of "Thu, 07 Apr 2005 17:09:34 PDT." <20050407170934.5ca77ab5@dxpl.pdx.osdl.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Stephen Hemminger <shemminger@osdl.org> wrote:

[...]
>Also: how do you intend to use the ABI version exported? Unless you have  a clear
>plan, it is frowned upon to drop random version numbers around hoping to be able
>to have compatibility.

	If by "ABI version exported," you're referring to this (and the
associated calls):

+int bond_check_abi_ver(void)
+{
+	int retval = 1;
+ +	if (orig_app_abi_ver == -1) {
+		orig_app_abi_ver  = BOND_ABI_VERSION;
+		app_abi_ver = BOND_ABI_VERSION;
+	}
+	else {
+		if (app_abi_ver == 0)
+			retval = 0;
+	}
+
+	return retval;
+}
+

	This enforces the already existing ABI version control stuff in
bonding (which deals with different versions of the ifenslave control
program).  This should preserve the existing ifenslave (ioctl based)
ABI.  I've only skimmed the patch, so I haven't tested it out as yet,
but at first glance it looks ok.

	Or did you mean something else?

	-J

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
