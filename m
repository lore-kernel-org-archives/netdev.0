From: Casey Schaufler <casey@schaufler-ca.com>
Subject: Re: linux-next: Tree for Nov 29 (netlabel)
Date: Fri, 30 Nov 2012 09:22:34 -0800
Message-ID: <50B8EB5A.3000307@schaufler-ca.com>
References: <20121129174057.99da02b15426c76054d05592@canb.auug.org.au> <50B7F846.70202@infradead.org> <3694027.VYznNcdp7C@sifl> <2664553.2TRaVqlkGg@sifl> <50B8E4E6.2040901@xenotime.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Paul Moore <paul@paul-moore.com>,
	Stephen Rothwell <sfr@canb.auug.org.au>,
	linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	linux-security-module@vger.kernel.org,
	Casey Schaufler <casey@schaufler-ca.com>
To: Randy Dunlap <rdunlap@xenotime.net>
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <50B8E4E6.2040901@xenotime.net>
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 11/30/2012 8:55 AM, Randy Dunlap wrote:
> On 11/30/2012 07:31 AM, Paul Moore wrote:
>
>> On Friday, November 30, 2012 10:19:16 AM Paul Moore wrote:
>>> On Thursday, November 29, 2012 04:05:26 PM Randy Dunlap wrote:
>>>> On 11/28/2012 10:40 PM, Stephen Rothwell wrote:
>>>>> Hi all,
>>>>> Changes since 20121128:
>>>> (on i386:)
>>> If I had to guess it looks like CONFIG_NETLABEL needs to be dependent on
>>> CONFIG_INET.  While the net/ Kconfig only pulls in the net/netlabel Kconfig
>>> if CONFIG_INET is defined, I'm guessing that without the explicit
>>> dependency there is nothing preventing someone from arriving at a bad
>>> configuration as we see here.
>>>
>>> Let me test this out to make sure my reasoning is right and if it is I'll
>>> post a patch to netdev later today.
>>>
>>> Thanks for catching this.
>> Hmmm.  The existing logic in net/Kconfig seems to disable CONFIG_NETLABEL at 
>> build time whenever CONFIG_INET is disabled in my .config file.  The only way 
>> I can recreate what you are seeing here is if I move the NetLabel include 
>> outside of the INET conditional in net/Kconfig.
>>
>> Regardless, adding an explicit dependency on INET to NETLABEL shouldn't hurt 
>> anything so I'll go ahead and post the patch to netdev.  Hopefully someone who 
>> understands Kconfig better than I do can help shed some light on this.
> Sorry, this patch doesn't help.
>
> I just checked the kernel .config again.  SECURITY_SMACK
> selects NETLABEL even when INET is not enabled.  Bad SMACK.

I'll send the patch properly, but it'll look like this.

 security/smack/Kconfig |    1 +
 1 file changed, 1 insertion(+)

diff --git a/security/smack/Kconfig b/security/smack/Kconfig
index 9fb14ef..1be1088 100644
--- a/security/smack/Kconfig
+++ b/security/smack/Kconfig
@@ -1,5 +1,6 @@
 config SECURITY_SMACK
 	bool "Simplified Mandatory Access Control Kernel Support"
+	depends on INET
 	depends on NET
 	depends on SECURITY
 	select NETLABEL


>
> I added Casey and mailing list to the cc:
>
>>>> net/built-in.o: In function `netlbl_cfg_cipsov4_add':
>>>> (.text+0x61757): undefined reference to `cipso_v4_doi_add'
>>>> net/built-in.o: In function `netlbl_cfg_cipsov4_del':
>>>> (.text+0x6177d): undefined reference to `cipso_v4_doi_remove'
>>>> net/built-in.o: In function `netlbl_cfg_cipsov4_map_add':
>>>> (.text+0x617ae): undefined reference to `cipso_v4_doi_getdef'
>>>> net/built-in.o: In function `netlbl_cfg_cipsov4_map_add':
>>>> (.text+0x61a49): undefined reference to `cipso_v4_doi_putdef'
>>>> net/built-in.o: In function `netlbl_sock_setattr':
>>>> (.text+0x6218c): undefined reference to `cipso_v4_sock_setattr'
>>>> net/built-in.o: In function `netlbl_sock_delattr':
>>>> (.text+0x6220b): undefined reference to `cipso_v4_sock_delattr'
>>>> net/built-in.o: In function `netlbl_sock_getattr':
>>>> (.text+0x62238): undefined reference to `cipso_v4_sock_getattr'
>>>> net/built-in.o: In function `netlbl_conn_setattr':
>>>> (.text+0x622de): undefined reference to `cipso_v4_sock_setattr'
>>>> net/built-in.o: In function `netlbl_conn_setattr':
>>>> (.text+0x62303): undefined reference to `cipso_v4_sock_delattr'
>>>> net/built-in.o: In function `netlbl_req_setattr':
>>>> (.text+0x62429): undefined reference to `cipso_v4_req_setattr'
>>>> net/built-in.o: In function `netlbl_req_setattr':
>>>> (.text+0x6244e): undefined reference to `cipso_v4_req_delattr'
>>>> net/built-in.o: In function `netlbl_req_delattr':
>>>> (.text+0x624ba): undefined reference to `cipso_v4_req_delattr'
>>>> net/built-in.o: In function `netlbl_skbuff_setattr':
>>>> (.text+0x62551): undefined reference to `cipso_v4_skbuff_setattr'
>>>> net/built-in.o: In function `netlbl_skbuff_setattr':
>>>> (.text+0x62576): undefined reference to `cipso_v4_skbuff_delattr'
>>>> net/built-in.o: In function `netlbl_skbuff_getattr':
>>>> (.text+0x62619): undefined reference to `cipso_v4_skbuff_getattr'
>>>> net/built-in.o: In function `netlbl_skbuff_err':
>>>> (.text+0x62685): undefined reference to `cipso_v4_error'
>>>> net/built-in.o: In function `netlbl_cache_invalidate':
>>>> (.text+0x626ab): undefined reference to `cipso_v4_cache_invalidate'
>>>> net/built-in.o: In function `netlbl_cache_add':
>>>> (.text+0x626ec): undefined reference to `cipso_v4_cache_add'
>>>> net/built-in.o: In function `netlbl_domhsh_remove_entry':
>>>> (.text+0x63294): undefined reference to `cipso_v4_doi_putdef'
>>>> net/built-in.o: In function `netlbl_domhsh_remove_entry':
>>>> (.text+0x632eb): undefined reference to `cipso_v4_doi_putdef'
>>>> net/built-in.o: In function `netlbl_domhsh_remove_af4':
>>>> (.text+0x6349b): undefined reference to `cipso_v4_doi_putdef'
>>>> net/built-in.o: In function `netlbl_mgmt_add_common.clone.1':
>>>> netlabel_mgmt.c:(.text+0x64a87): undefined reference to
>>>> `cipso_v4_doi_getdef' netlabel_mgmt.c:(.text+0x64c83): undefined reference
>>>> to `cipso_v4_doi_putdef' net/built-in.o: In function
>>>> `netlbl_cipsov4_listall':
>>>> netlabel_cipso_v4.c:(.text+0x66e52): undefined reference to
>>>> `cipso_v4_doi_walk' net/built-in.o: In function `netlbl_cipsov4_list':
>>>> netlabel_cipso_v4.c:(.text+0x67199): undefined reference to
>>>> `cipso_v4_doi_getdef' net/built-in.o: In function `netlbl_cipsov4_remove':
>>>> netlabel_cipso_v4.c:(.text+0x6771b): undefined reference to
>>>> `cipso_v4_doi_remove' net/built-in.o: In function
>>>> `netlbl_cipsov4_add_pass':
>>>> netlabel_cipso_v4.c:(.text+0x67a4b): undefined reference to
>>>> `cipso_v4_doi_add' netlabel_cipso_v4.c:(.text+0x67a76): undefined
>>>> reference
>>>> to `cipso_v4_doi_free' net/built-in.o: In function
>>>> `netlbl_cipsov4_add_local':
>>>> netlabel_cipso_v4.c:(.text+0x67b9a): undefined reference to
>>>> `cipso_v4_doi_add' netlabel_cipso_v4.c:(.text+0x67bc5): undefined
>>>> reference
>>>> to `cipso_v4_doi_free' net/built-in.o: In function
>>>> `netlbl_cipsov4_add_std':
>>>> netlabel_cipso_v4.c:(.text+0x68535): undefined reference to
>>>> `cipso_v4_doi_add' netlabel_cipso_v4.c:(.text+0x68575): undefined
>>>> reference
>>>> to `cipso_v4_doi_free'
>>>>
>>>>
>>>> Full randconfig file is attached.
>
>

