From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/3] Networking: use CAP_NET_ADMIN when deciding to
 call request_module
Date: Thu, 13 Aug 2009 16:14:50 -0700 (PDT)
Message-ID: <20090813.161450.193138821.davem@davemloft.net>
References: <20090813134451.29186.41664.stgit@paris.rdu.redhat.com>
	<200908131445.37263.paul.moore@hp.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eparis@redhat.com, linux-kernel@vger.kernel.org,
	selinux@tycho.nsa.gov, netdev@vger.kernel.org,
	linux-security-module@vger.kernel.org, sds@tycho.nsa.gov,
	shemminger@linux-foundation.org, kees@ubuntu.com,
	morgan@kernel.org, casey@schaufler-ca.com, dwalsh@redhat.com
To: paul.moore@hp.com
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1756439AbZHMXOl@vger.kernel.org>
In-Reply-To: <200908131445.37263.paul.moore@hp.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Paul Moore <paul.moore@hp.com>
Date: Thu, 13 Aug 2009 14:45:37 -0400

> On Thursday 13 August 2009 09:44:51 am Eric Paris wrote:
>> The networking code checks CAP_SYS_MODULE before using request_module() to
>> try to load a kernel module.  While this seems reasonable it's actually
>> weakening system security since we have to allow CAP_SYS_MODULE for things
>> like /sbin/ip and bluetoothd which need to be able to trigger module loads.
>> CAP_SYS_MODULE actually grants those binaries the ability to directly load
>> any code into the kernel.  We should instead be protecting modprobe and the
>> modules on disk, rather than granting random programs the ability to load
>> code directly into the kernel.  Instead we are going to gate those
>> networking checks on CAP_NET_ADMIN which still limits them to root but
>> which does not grant those processes the ability to load arbitrary code
>> into the kernel.
>>
>> Signed-off-by: Eric Paris <eparis@redhat.com>
> 
> Sounds and looks reasonable to me.
> 
> Acked-by: Paul Moore <paul.moore@hp.com>

Looks fine to me:

Acked-by: David S. Miller <davem@davemloft.net>
