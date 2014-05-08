From: "Wisniewski, Krzysztof" <krzysztof.wisniewski@intel.com>
Subject: [how to] modify initrd.img from RHEL6.5_tftpboot to
 include i40e module
Date: Thu, 8 May 2014 10:19:09 +0000
Message-ID: <B48049383861234BA9F90C37DCBC24F92240AF9D@IRSMSX104.ger.corp.intel.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
	boundary="_004_B48049383861234BA9F90C37DCBC24F92240AF9DIRSMSX104gercor_"
Cc: "Gafka, Aleksander" <aleksander.gafka@intel.com>, "Lawton,
	Shanon R" <shanon.r.lawton@intel.com>, "Ciesielski,
	Dariusz K" <dariusz.k.ciesielski@intel.com>, "Ronciak,
	John" <john.ronciak@intel.com>, "Wallace,
	Andrew" <andrew.wallace@intel.com>, "Morgan,
	Jack" <jack.morgan@intel.com>, "Kepczynski,
	Tomasz" <tomasz.kepczynski@intel.com>, "Kulkarni,
	Suyog D" <suyog.d.kulkarni@intel.com>
To: "e1000-devel@lists.sourceforge.net" <e1000-devel@lists.sourceforge.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
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

--_004_B48049383861234BA9F90C37DCBC24F92240AF9DIRSMSX104gercor_
Content-Type: multipart/alternative;
	boundary="_000_B48049383861234BA9F90C37DCBC24F92240AF9DIRSMSX104gercor_"

--_000_B48049383861234BA9F90C37DCBC24F92240AF9DIRSMSX104gercor_
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi,
Looking for help with RHEL 6.5 initrd.img modification to include i40e modu=
le for 40G adapter to perform legacy PXE boot on it.

What I try to acomplish: 40G PXE boot of RHEL 6.5 on 40G NIC with PCI ID x1=
572.

What I do:
-install RHEL 6.5 with kernel 2.6.32-431.el6.x86_64, retrieve tftpboot init=
rd.img and make o copy of it in /tmp
-build i40e module and test that it works correctly
-exctract the content of initrd.img in /tmp with xz and cpio ->
                mv initrd.img initrd.img.xz
                xz -d -F lzma initrd.img.xz
                mkdir initrd
                cd initrd-new
                cpio -ivdum < ../initrd.img
-add i40e module into initrd ->
                copy i40e.ko into /tmp/initrd/modules/2.6.32-431.el6.x86_64=
/kernel/drivers/net/i40e/
                gzip i40e.ko
                modify files: module-info, modules.alias, modules.dep, modu=
les.networking, modules.pcimap
                run: depmod -b initrd -a and verify with: modinfo -b initrd=
 i40e
-build initrd into initrd.img ->
                find . -print |cpio -o -H newc | xz -F lzma > ../initrd.img
-copy generated initrd.img into PXE linux server into tftpboot data
-reboot platform, select PXE boot on 40G NIC and RHEL 6.5 tftpboot initrd.i=
mg is loaded and fails to find 40G networking interface...
with info as in attached file: module i40e not found.....

I would appreciate any hints or links on how to incorporate i40e module int=
o tftpboot initrd.img in RHEL6 ?
Thanks a lot, regards, krzysztof wisniewski
--------------------------------------------------------------------

Intel Technology Poland sp. z o.o.
ul. Slowackiego 173 | 80-298 Gdansk | Sad Rejonowy Gdansk Polnoc | VII Wydz=
ial Gospodarczy Krajowego Rejestru Sadowego - KRS 101882 | NIP 957-07-52-31=
6 | Kapital zakladowy 200.000 PLN.

Ta wiadomosc wraz z zalacznikami jest przeznaczona dla okreslonego adresata=
 i moze zawierac informacje poufne. W razie przypadkowego otrzymania tej wi=
adomosci, prosimy o powiadomienie nadawcy oraz trwale jej usuniecie; jakiek=
olwiek przegladanie lub rozpowszechnianie jest zabronione.
This e-mail and any attachments may contain confidential material for the s=
ole use of the intended recipient(s). If you are not the intended recipient=
, please contact the sender and delete all copies; any review or distributi=
on by others is strictly prohibited.

--_000_B48049383861234BA9F90C37DCBC24F92240AF9DIRSMSX104gercor_--

--_004_B48049383861234BA9F90C37DCBC24F92240AF9DIRSMSX104gercor_
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

------------------------------------------------------------------------------
Is your legacy SCM system holding you back? Join Perforce May 7 to find out:
&#149; 3 signs your SCM is hindering your productivity
&#149; Requirements for releasing software faster
&#149; Expert tips and advice for migrating your SCM now
http://p.sf.net/sfu/perforce
--_004_B48049383861234BA9F90C37DCBC24F92240AF9DIRSMSX104gercor_
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired

--_004_B48049383861234BA9F90C37DCBC24F92240AF9DIRSMSX104gercor_--
