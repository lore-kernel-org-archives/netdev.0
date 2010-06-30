From: Harald Hoyer <harald@redhat.com>
Subject: Re: [PATCH] igbvf: avoid name clash between PF and VF
Date: Wed, 30 Jun 2010 15:07:35 +0200
Message-ID: <4C2B4197.6090206@redhat.com>
References: <4C2B0614.9040004@redhat.com> <1277894679.28819.60.camel@localhost>
	<4C2B22FD.4050705@redhat.com>
	<AANLkTin08wA8a5nCnq-djQnTSq1g2TQ7GqYfCEBCTn9l@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: e1000-devel@lists.sourceforge.net, netdev <netdev@vger.kernel.org>,
	gregory.v.rose@intel.com, jeffrey.t.kirsher@intel.com,
	Andy Gospodarek <gospo@redhat.com>,
	Ben Hutchings <bhutchings@solarflare.com>,
	Stefan Assmann <sassmann@redhat.com>
To: Kay Sievers <kay.sievers@vrfy.org>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <AANLkTin08wA8a5nCnq-djQnTSq1g2TQ7GqYfCEBCTn9l@mail.gmail.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

On 06/30/2010 01:11 PM, Kay Sievers wrote:
> On Wed, Jun 30, 2010 at 12:57, Stefan Assmann<sassmann@redhat.com>  wrote:
>> On 30.06.2010 12:44, Ben Hutchings wrote:
>>> On Wed, 2010-06-30 at 10:53 +0200, Stefan Assmann wrote:
>>>> From: Stefan Assmann<sassmann@redhat.com>
>>>>
>>>> It looks like the VFs get initialized before all the PFs are. Therefore
>>>> the udev mapping MAC<->  ethX (for PFs) gets screwed because the VFs
>>>> may grab the ethX interface names (reserved by udev) for the PFs.
>>>>
>>>> Example:
>>>> igb max_vfs=0
>>>> eth0      Link encap:Ethernet  HWaddr 00:13:20:F7:A5:9E
>>>> eth1      Link encap:Ethernet  HWaddr 00:13:20:F7:A5:9F
>>>> eth2      Link encap:Ethernet  HWaddr 00:13:20:F7:A5:A0
>>>> eth3      Link encap:Ethernet  HWaddr 00:13:20:F7:A5:A1
>>>> igb max_vfs=1
>>>> eth0      Link encap:Ethernet  HWaddr 00:13:20:F7:A5:9E
>>>> eth1      Link encap:Ethernet  HWaddr 0A:CF:41:69:F7:A9
>>>> eth2      Link encap:Ethernet  HWaddr 3A:FE:20:4C:2A:3B
>>>> eth3      Link encap:Ethernet  HWaddr C6:C3:B1:56:C9:A4
>>>> eth3_rename Link encap:Ethernet  HWaddr 00:13:20:F7:A5:9F
>>>> eth4      Link encap:Ethernet  HWaddr 6E:8A:8A:A3:5F:69
>>>> eth4_rename Link encap:Ethernet  HWaddr 00:13:20:F7:A5:A0
>>>> eth5_rename Link encap:Ethernet  HWaddr 00:13:20:F7:A5:A1
>>>>
>>>> In the example above VF 0A:CF:41:69:F7:A9 grabs eth1 but udev
>>>> has a rule that says eth1 should be assigned PF 00:13:20:F7:A5:9F
>>>> (eth3_rename) and waits for the VF to disappear to rename eth3_rename
>>>> to eth1. Unfortunately eth1 is not going to disappear.
>>>> This is not a udev bug since udev doesn't create persistent rules for
>>>> VFs as their MAC address changes every reboot.
>>> [...]
>>>
>>> I think it is a bug in the udev rules: udev should rename the VFs even
>>> though their names won't be persistent.
>
> Udev writes out these configs to a rules file, and therefore can never
> handle random MAC addresses, as they would just accumulate in the
> rules file with a new entry at every bootup.
>
> Stuff like this is just not supported at the moment with the rather
> simple logic it has, and there is no current plan/idea, or anybody
> working on changing/improving this at the moment.
>
> Kay

Solution: move away from the "eth*" namespace and use "net*" for configured 
interfaces.

------------------------------------------------------------------------------
This SF.net email is sponsored by Sprint
What will you do first with EVO, the first 4G phone?
Visit sprint.com/first -- http://p.sf.net/sfu/sprint-com-first
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
