From: Varka Bhadram <varkabhadram@gmail.com>
Subject: Re: [PATCH 2/2 V3] PCI: implement VFs assignment
	reference counter
Date: Fri, 11 Jul 2014 18:26:36 +0530
Message-ID: <53BFDF04.7090906@gmail.com>
References: <1405081802-419-1-git-send-email-ethan.zhao@oracle.com>	<1405081802-419-2-git-send-email-ethan.zhao@oracle.com>	<53BFDBC0.8000705@gmail.com>
	<CABawtvOV5DQqqLu96CFktxmHkJA+n3FUyA3Nt3HtPMKs5KpVOw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============2649968982497602119=="
Cc: "<kvm@vger.kernel.org>" <kvm@vger.kernel.org>,
	linux-pci <linux-pci@vger.kernel.org>,
	"e1000-devel@lists.sourceforge.net" <e1000-devel@lists.sourceforge.net>,
	"vaughan.cao@oracle.com" <vaughan.cao@oracle.com>, "Brandeburg,
	Jesse" <jesse.brandeburg@intel.com>, Ethan Zhao <ethan.zhao@oracle.com>,
	"<linux.nics@intel.com>" <linux.nics@intel.com>,
	Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>,
	"<gleb@kernel.org>" <gleb@kernel.org>,
	"<alex.williamson@redhat.com>" <alex.williamson@redhat.com>,
	Bjorn Helgaas <bhelgaas@google.com>,
	"<boris.ostrovsky@oracle.com>" <boris.ostrovsky@oracle.com>,
	netdev <netdev@vger.kernel.org>, "Allan,
	Bruce W" <bruce.w.allan@intel.com>, LKML <linux-kernel@vger.kernel.org>,
	"<john.ronciak@intel.com>" <john.ronciak@intel.com>,
	David Vrabel <david.vrabel@citrix.com>,
	"<pbonzini@redhat.com>" <pbonzini@redhat.com>
To: Ethan Zhao <ethan.kernel@gmail.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <CABawtvOV5DQqqLu96CFktxmHkJA+n3FUyA3Nt3HtPMKs5KpVOw@mail.gmail.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--===============2649968982497602119==
Content-Type: multipart/alternative;
	boundary="------------050002060201000302080704"

This is a multi-part message in MIME format.
--------------050002060201000302080704
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 8bit

On 07/11/2014 06:21 PM, Ethan Zhao wrote:
> On Fri, Jul 11, 2014 at 8:42 PM, Varka Bhadram <varkabhadram@gmail.com> wrote:
>> On 07/11/2014 06:00 PM, Ethan Zhao wrote:
>>> Current implementation of helper function pci_vfs_assigned() is a
>>> little complex, to get sum of VFs that assigned to VM, access low
>>> level configuration space register and then loop in traversing
>>> device tree.
>>
>> (...)
>>
>>
>>> @@ -650,6 +630,11 @@ EXPORT_SYMBOL_GPL(pci_vfs_assigned);
>>>    void pci_iov_assign_device(struct pci_dev *pdev)
>>>    {
>>>          pdev->dev_flags |= PCI_DEV_FLAGS_ASSIGNED;
>>> +       if (pdev->is_virtfn && !pdev->is_physfn)
>>> +               if (pdev->physfn)
>>> +                       if (pdev->physfn->sriov)
>>
>> Why don't we make last two 'if' conditions into single 'if'
>>
>> if (pdev->physfn && pdev->physfn->sriov)
> Yeah， this one looks better,  that style used to tell myself, I might
> forget the which side of  && operator  first, if you sure left first,
> I prefer that too :>

|for &&  operator - evaluation is from Left to Right|

-- 
Regards,
Varka Bhadram.


--------------050002060201000302080704--


--===============2649968982497602119==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

------------------------------------------------------------------------------
Open source business process management suite built on Java and Eclipse
Turn processes into business applications with Bonita BPM Community Edition
Quickly connect people, data, and systems into organized workflows
Winner of BOSSIE, CODIE, OW2 and Gartner awards
http://p.sf.net/sfu/Bonitasoft
--===============2649968982497602119==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired

--===============2649968982497602119==--
