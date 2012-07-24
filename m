From: KY Srinivasan <kys@microsoft.com>
Subject: RE: [PATCH 10/17] Tools: hv: Gather ipv[4,6] gateway information
Date: Tue, 24 Jul 2012 17:17:23 +0000
Message-ID: <426367E2313C2449837CD2DE46E7EAF9236A776D@SN2PRD0310MB382.namprd03.prod.outlook.com>
References: <1343145672-3641-1-git-send-email-kys@microsoft.com>
 <1343145701-3691-1-git-send-email-kys@microsoft.com>
 <1343145701-3691-10-git-send-email-kys@microsoft.com>
 <20120724092914.60f3d90a@nehalam.linuxnetplumber.net>
 <20120724165359.GA8409@aepfle.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "gregkh@linuxfoundation.org" <gregkh@linuxfoundation.org>,
 "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
 "virtualization@lists.osdl.org" <virtualization@lists.osdl.org>,
 "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
 "apw@canonical.com" <apw@canonical.com>,
 "devel@linuxdriverproject.org" <devel@linuxdriverproject.org>,
 "ben@decadent.org.uk" <ben@decadent.org.uk>
To: Olaf Hering <olaf@aepfle.de>, Stephen Hemminger <shemminger@vyatta.com>
Return-path: <devel-bounces@linuxdriverproject.org>
In-Reply-To: <20120724165359.GA8409@aepfle.de>
Content-Language: en-US
List-Unsubscribe: <http://driverdev.linuxdriverproject.org/mailman/options/devel>,
 <mailto:devel-request@linuxdriverproject.org?subject=unsubscribe>
List-Archive: <http://driverdev.linuxdriverproject.org/pipermail/devel>
List-Post: <mailto:devel@linuxdriverproject.org>
List-Help: <mailto:devel-request@linuxdriverproject.org?subject=help>
List-Subscribe: <http://driverdev.linuxdriverproject.org/mailman/listinfo/devel>,
 <mailto:devel-request@linuxdriverproject.org?subject=subscribe>
Errors-To: devel-bounces@linuxdriverproject.org
Sender: devel-bounces@linuxdriverproject.org
List-Id: netdev.vger.kernel.org



> -----Original Message-----
> From: Olaf Hering [mailto:olaf@aepfle.de]
> Sent: Tuesday, July 24, 2012 12:54 PM
> To: Stephen Hemminger
> Cc: KY Srinivasan; gregkh@linuxfoundation.org; linux-kernel@vger.kernel.org;
> devel@linuxdriverproject.org; virtualization@lists.osdl.org; apw@canonical.com;
> netdev@vger.kernel.org; ben@decadent.org.uk
> Subject: Re: [PATCH 10/17] Tools: hv: Gather ipv[4,6] gateway information
> 
> On Tue, Jul 24, Stephen Hemminger wrote:
> 
> > On Tue, 24 Jul 2012 09:01:34 -0700
> > "K. Y. Srinivasan" <kys@microsoft.com> wrote:
> >
> > > +	memset(cmd, 0, sizeof(cmd));
> > > +	strcat(cmd, "/sbin/ip -f inet  route | grep -w ");
> > > +	strcat(cmd, if_name);
> > > +	strcat(cmd, " | awk '/default/ {print $3 }'");
> >
> >
> > Much simpler method:
> >
> > ip route show match 0/0
> 
> This also has the benefit that ip is not called with absolute path, now
> that distros move binaries around.

I could have chosen to not specify the full path for the ip command and for that
matter all the external scripts I invoke from the KVP daemon. Do you mind if I 
submitted a patch to get rid of the absolute paths in this code.

Stephen's suggestion is clearly simpler (I don't need to invoke awk to filter what 
we want). Steve, I could make this change as well as an additional patch.

Regards,

K. Y 
