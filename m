From: Rick Jones <rick.jones2@hpe.com>
Subject: Re: [PATCH v12 net-next 1/1] hv_sock: introduce Hyper-V Sockets
Date: Tue, 28 Jun 2016 08:42:48 -0700
Message-ID: <57729AF8.3050708@hpe.com>
References: <BLUPR03MB1410A0ECB526A1CD13814D36BF2E0@BLUPR03MB1410.namprd03.prod.outlook.com>
 <20160628.053350.1891488485477523405.davem@davemloft.net>
 <CO2PR03MB2182CC1DA2804F09D8D77A70BF220@CO2PR03MB2182.namprd03.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "gregkh@linuxfoundation.org" <gregkh@linuxfoundation.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"devel@linuxdriverproject.org" <devel@linuxdriverproject.org>,
	"olaf@aepfle.de" <olaf@aepfle.de>,
	"apw@canonical.com" <apw@canonical.com>,
	"jasowang@redhat.com" <jasowang@redhat.com>,
	"vkuznets@redhat.com" <vkuznets@redhat.com>,
	"cavery@redhat.com" <cavery@redhat.com>,
	KY Srinivasan <kys@microsoft.com>,
	Haiyang Zhang <haiyangz@microsoft.com>,
	"joe@perches.com" <joe@perches.com>
To: Dexuan Cui <decui@microsoft.com>,
	David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CO2PR03MB2182CC1DA2804F09D8D77A70BF220@CO2PR03MB2182.namprd03.prod.outlook.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 06/28/2016 02:59 AM, Dexuan Cui wrote:
> The idea here is: IMO the syscalls sys_read()/write() shoudn't return
> -ENOMEM, so I have to make sure the buffer allocation succeeds?
>
> I tried to use kmalloc with __GFP_NOFAIL, but I hit a warning in
> in mm/page_alloc.c:
> WARN_ON_ONCE((gfp_flags & __GFP_NOFAIL) && (order > 1));
>
> What error code do you think I should return?
> EAGAIN, ERESTARTSYS, or something else?
>
> May I have your suggestion? Thanks!

What happens as far as errno is concerned when an application makes a 
read() call against a (say TCP) socket associated with a connection 
which has been reset?  Is it limited to those errno values listed in the 
read() manpage, or does it end-up getting an errno value from those 
listed in the recv() manpage?  Or, perhaps even one not (presently) 
listed in either?

rick jones
