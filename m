From: "Rose, Gregory V" <gregory.v.rose@intel.com>
Subject: Re: ixgbe: macvlan on PF/VF when SRIOV is enabled
Date: Mon, 24 May 2010 10:54:46 -0700
Message-ID: <43F901BD926A4E43B106BF17856F0755A79C0E05@orsmsx508.amr.corp.intel.com>
References: <1274473846.8701.25.camel@localhost.localdomain>
	<43F901BD926A4E43B106BF17856F0755A79C099C@orsmsx508.amr.corp.intel.com>
	<1274720919.18023.19.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "e1000-devel@lists.sourceforge.net" <e1000-devel@lists.sourceforge.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>, "Kirsher,
	Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"kvm@vger.kernel.org" <kvm@vger.kernel.org>,
	"davem@davemloft.net" <davem@davemloft.net>
To: Shirley Ma <mashirle@us.ibm.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <1274720919.18023.19.camel@localhost.localdomain>
Content-Language: en-US
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

>-----Original Message-----
>From: Shirley Ma [mailto:mashirle@us.ibm.com]
>Sent: Monday, May 24, 2010 10:09 AM
>To: Rose, Gregory V
>Cc: Kirsher, Jeffrey T; davem@davemloft.net; kvm@vger.kernel.org;
>netdev@vger.kernel.org; e1000-devel@lists.sourceforge.net
>Subject: RE: ixgbe: macvlan on PF/VF when SRIOV is enabled
>
>Hello Greg,
>
>Thanks for your prompt response.
>
>On Sat, 2010-05-22 at 10:53 -0700, Rose, Gregory V wrote:
>> As of 2.6.34 the ixgbe driver does not support multiple queues for
>> macvlan.
>> Support for multiple queues for macvlan will come in a subsequent
>> release.
>
>When it might happen?

Support for multiple queues in the PF driver is in the planning stage right now.  Hopefully we'll get it in sooner rather than later but I can't give any solid dates for it.

 I will double check my test to see whether macvlan
>was multiple queue or not.

Ah, so you just want to set multiple macvlan filters for the PF driver but aren't concerned about directing the traffic to different queues?  We haven't tested that in SR-IOV modes of operation but we can have a look at it.

Then submitting my experimental patch for
>review.

We look forward to it and will be happy to provide feedback.

>
>> The VF driver does not support macvlan.  Future releases may but there
>> are no immediate plans to support it.
>
>When it might be support in future. For performance reason, we are
>interested in macvlan + VF for multiples VMs.

There is a resource contention issue in this case.  There are 128 MAC filters available.  When VFs are allocated each will use a MAC filter entry.  In the case where the maximum number of VFs are allocated (63 in this case) there aren't a whole lot of MAC filters left over to spread across that many VFs.  Our view has been that it wouldn't be that much added value to support macvlan in the VFs but if there is a good case for it we'll consider it.

One thing you can do is allocate VFs and then load the VF driver in your host domain and then assign each of them a macvlan filter.  You'd get a similar effect.

>
>One more question here: Does VF support promiscuous mode? I don't see
>the flag in ixgbevf driver.

No, there is no per-VF support for promiscuous mode in the HW as such, however you could set the unicast hash table array to all ones and then set the VFs you want to be in promiscuous mode to accept untagged packets via the VM filtering and offload register at offset 0F000h.  However, re-provisioning the UTA for this purpose would preclude using it for the designed purpose.

I suggest that you pick up a copy of the developer's manual for the 82599 at the Intel developer's site.

http://developer.intel.com/products/ethernet/index.htm?iid=nc+ethernet#s1=all&s2=82576EB&s3=all

- Greg

------------------------------------------------------------------------------

_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
