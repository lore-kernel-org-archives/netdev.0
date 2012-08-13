From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: Re: [PATCH V2 09/12] net/eipoib: Add main driver functionality
Date: Mon, 13 Aug 2012 11:33:18 +0300
Message-ID: <5028BBCE.4020908@mellanox.com>
References: <1343840975-3252-1-git-send-email-ogerlitz@mellanox.com> <1343840975-3252-10-git-send-email-ogerlitz@mellanox.com> <87boitz044.fsf@xmission.com> <20120805185031.GA18640@redhat.com> <CAJZOPZKtdvxTGvrxj+T896mEexb=yN9s1cCuqUmhhzCOvUPEnA@mail.gmail.com> <877gt415lu.fsf@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Michael S. Tsirkin" <mst@redhat.com>, <davem@davemloft.net>,
	<roland@kernel.org>, <netdev@vger.kernel.org>, <ali@mellanox.com>,
	<sean.hefty@intel.com>, Erez Shitrit <erezsh@mellanox.co.il>,
	Doug Ledford <dledford@redhat.com>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog114.obsmtp.com ([207.126.144.137]:38162 "HELO
	eu1sys200aog114.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1751067Ab2HMIfu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Aug 2012 04:35:50 -0400
In-Reply-To: <877gt415lu.fsf@xmission.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/08/2012 18:40, Eric W. Biederman wrote:
> Let me give you a non-hack recomendation.
>
> - Give up on being wire compatible with IPoIB.
>
> - Define and implement ethernet over inifiniband aka EoIB.
>
> With EoIB:
> - The SM would map ethernet address to inifiniband hardware addresses.
> - You discover which multicast addresses are of interest from the
>    IP layer above so no snooping is necessary.
> - You could run queue pairs directly to hosts.
>
> Shrug.  It is trivial and it will work.  It will probably run into the
> same problems that have historically been a problem for using IPoIB
> (lack of stateless offloads) but shrug that is mostly a NIC firmware
> problem.  The switches will have no trouble and interoperability will
> be assured.
>
> If you want to map ethernet over infiniband please map ethernet over
> infiniband.  Don't poorly NAT ethernet into infiniband.
>
>


EoIB is a valid suggestion and we will look into it as well, BUT:

Providing EoIB is a separate discussion, obviously defining and 
standardizing a new protocol takes what is takes (a lot of time, longish 
term effort), and will also take time to develop/debug/mature e.g as you 
mentioned, some of the features/offloads might require new NIC HW, etc 
-- compared to IPoIB which is here for many years

In practice there is already a huge install base for IPoIB software and 
hardware products, in different operating environments/OS. We can't just 
through away everything and tell people to replace it all with a new 
protocol, e.g. bridging devices, storage systems/appliances, VMware, 
Windows, .. systems in production environments --- so
the interoperability concern you've mentioned gonna hit very hard.

The eIPoIB driver comes to provide a way to work with IPoIB in 
virtualized environments, where still, the suggestions/concerns raised 
in this thread should be addressed.

Or.
