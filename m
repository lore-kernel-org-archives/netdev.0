From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 1/3] VMCI: only load on VMware hypervisor
Date: Wed, 16 Aug 2017 11:06:35 -0700 (PDT)
Message-ID: <20170816.110635.1062040564700704290.davem@davemloft.net>
References: <KL1P15301MB00083C97259FF2A700C78442BF8D0@KL1P15301MB0008.APCP153.PROD.OUTLOOK.COM>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gregkh@linuxfoundation.org,
        devel@linuxdriverproject.org, kys@microsoft.com,
        haiyangz@microsoft.com, sthemmin@microsoft.com,
        georgezhang@vmware.com, jhansen@vmware.com, mkubecek@suse.cz,
        asias@redhat.com, stefanha@redhat.com, vkuznets@redhat.com,
        cavery@redhat.com, jasowang@redhat.com, rolf.neugebauer@docker.com,
        dave.scott@docker.com, marcelo.cerri@canonical.com,
        apw@canonical.com, olaf@aepfle.de, joe@perches.com,
        linux-kernel@vger.kernel.org, dan.carpenter@oracle.com
To: decui@microsoft.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <KL1P15301MB00083C97259FF2A700C78442BF8D0@KL1P15301MB0008.APCP153.PROD.OUTLOOK.COM>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Dexuan Cui <decui@microsoft.com>
Date: Tue, 15 Aug 2017 22:13:29 +0000

> +	/*
> +	 * Check if we are running on VMware's hypervisor and bail out
> +	 * if we are not.
> +	 */
> +	if (x86_hyper != &x86_hyper_vmware)
> +		return -ENODEV;

This symbol is only available when CONFIG_HYPERVISOR_GUEST is defined.
But this driver does not have a Kconfig dependency on that symbol so
the build can fail in some configurations.
