From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: Re: [PATCH V1 net-next 1/1] hyperv: Enable sendbuf mechanism on the
 send path
Date: Fri, 25 Apr 2014 01:30:59 +0300
Message-ID: <20140424223059.GE26890@mwanda>
References: <1398288285-16268-1-git-send-email-kys@microsoft.com>
 <CAJUuVQ7V+Se0auKdaiqPZr8i2WcNqWhHUwz8r85DKKCjnjtrvQ@mail.gmail.com>
 <cdb70820bcd0467586ce6893753c7065@BY2PR03MB299.namprd03.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "olaf@aepfle.de" <olaf@aepfle.de>, Andev <debiandev@gmail.com>,
 "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
 "jasowang@redhat.com" <jasowang@redhat.com>,
 LKML <linux-kernel@vger.kernel.org>, "apw@canonical.com" <apw@canonical.com>,
 "devel@linuxdriverproject.org" <devel@linuxdriverproject.org>,
 "davem@davemloft.net" <davem@davemloft.net>
To: KY Srinivasan <kys@microsoft.com>
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
Content-Disposition: inline
In-Reply-To: <cdb70820bcd0467586ce6893753c7065@BY2PR03MB299.namprd03.prod.outlook.com>
List-Unsubscribe: <http://driverdev.linuxdriverproject.org/mailman/options/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=unsubscribe>
List-Archive: <http://driverdev.linuxdriverproject.org/pipermail/driverdev-devel>
List-Post: <mailto:driverdev-devel@linuxdriverproject.org>
List-Help: <mailto:driverdev-devel-request@linuxdriverproject.org?subject=help>
List-Subscribe: <http://driverdev.linuxdriverproject.org/mailman/listinfo/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=subscribe>
Errors-To: driverdev-devel-bounces@linuxdriverproject.org
Sender: driverdev-devel-bounces@linuxdriverproject.org
List-Id: netdev.vger.kernel.org

On Thu, Apr 24, 2014 at 10:06:24PM +0000, KY Srinivasan wrote:
> > From: Andev [mailto:debiandev@gmail.com]
> > Your use of goto exit/cleanup in some functions and returning directly on
> > errors in others could use a cleanup. Please consider doing that while you are
> > touching those files.
> 
> Will do. The most recent changes I made to netvsc.c, I think was
> consistent with the existing code; going forward we will certainly
> move towards a more consistent coding style.

It scares me when you talk about being consistent with the existing
code...  Just do it the correct way.

1) Don't do the "return ret;" if you know ret is zero.

2) Replace:
	ret = vmbus_sendpacket(...);

	return ret;
   with
  	return vmbus_sendpacket(...);

3) Don't do "goto cleanup;" when "return ret;" will suffice.  The
   do-nothing goto is misleading because you assume it will cleanup
   somthing.  Some people used to misread CodingStyle to think that all
   functions should only have one return but I have updated it so it is
   more clear.

regards,
dan carpenter
