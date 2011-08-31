From: <rongqing.li@windriver.com>
Subject: [PATCH 0/2] Dump the sock's security context
Date: Wed, 31 Aug 2011 16:36:15 +0800
Message-ID: <1314779777-12669-1-git-send-email-rongqing.li@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain
To: <netdev@vger.kernel.org>, <selinux@tycho.nsa.gov>,
	<linux-security-module@vger.kernel.org>
Return-path: <linux-security-module-owner@vger.kernel.org>
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

-------
    Any review would be much appreciated.
 
Comments:
--------
    Add a netlink attribute INET_DIAG_SECCTX
    
    Add a new netlink attribute INET_DIAG_SECCTX to dump the security
    context of TCP sockets.
    
    The element sk_security of struct sock represents the socket
    security context ID, which is inherited from the parent process
    when the socket is created.
    
    but when SELinux type_transition rule is applied to socket, or
    application sets /proc/xxx/attr/createsock, the socket security
    context would be different from the creating process. For these
    conditions, the "netstat -Z" would return wrong value, since
    "netstat -Z" only returns the process security context as socket
    process security.


The application to verify the netlink new attribute.
------
See attached file

test:
--------
1. Enable SELinux when compile and startup .
	root@qemu-host:/root> ./printsocketsec
	 inode:7141 system_u:system_r:rpcbind_t:s0 
	 inode:7136 system_u:system_r:rpcbind_t:s0 
	 inode:7604 system_u:system_r:initrc_t:s0 
	 inode:7227 system_u:system_r:rpcd_t:s0 
	 inode:7471 system_u:system_r:sshd_t:s0-s0:c0.c1023 
	 inode:7469 system_u:system_r:sshd_t:s0-s0:c0.c1023 
	 inode:7552 system_u:system_r:sendmail_t:s0 
	 inode:7348 system_u:system_r:initrc_t:s0 
	 inode:7553 system_u:system_r:sendmail_t:s0 
	root@qemu-host:/root> 

2. Disable SELinux when startup.
	root@qemu-host:/root> ./printsocketsec 
	inode:3221 
	inode:2942 
	inode:2861 
	inode:3256 
	inode:3156 
	inode:3220 
	inode:3060
	root@qemu-host:/root>

3. Disable SELinux when compile and startup
	root@qemu-host:/root> ./printsocketsec 
	inode:3221 
	inode:2942 
	inode:2861 
	inode:3256 
	inode:3156 
	inode:3220 
	inode:3060
	root@qemu-host:/root>
