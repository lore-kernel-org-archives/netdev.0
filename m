From: "Denis V. Lunev" <den-3ImXcnM4P+0@public.gmane.org>
Subject: Re: [PATCH 2/2] move unneeded data to initdata section
Date: Thu, 15 Nov 2007 22:17:14 +0300
Message-ID: <473C9B3A.4020401@sw.ru>
References: <20071107120100.GA10185@iris.sw.ru>
	<m1abpfy3xz.fsf@ebiederm.dsl.xmission.com> <473C5ABC.5090204@sw.ru>
	<20071115151429.GC22825@uranus.ravnborg.org>
	<m13av7xtg1.fsf@ebiederm.dsl.xmission.com>
	<20071115184334.GC23914@uranus.ravnborg.org>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="------------090406030502050409000403"
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, clg-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org,
        "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org,
        "Denis V. Lunev" <den-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org,
        benjamin.thery-6ktuUTfB/bM@public.gmane.org
To: Sam Ravnborg <sam-uyr5N9Q2VtJg9hUCZPvPmw@public.gmane.org>
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20071115184334.GC23914-QabhHTsIXMSnlFQ6Q1D1Y0B+6BGkLq7r@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------090406030502050409000403
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit

Sam Ravnborg wrote:
> On Thu, Nov 15, 2007 at 11:19:26AM -0700, Eric W. Biederman wrote:
>> Sam Ravnborg <sam-uyr5N9Q2VtJg9hUCZPvPmw@public.gmane.org> writes:
>>
>>> On Thu, Nov 15, 2007 at 05:42:04PM +0300, Denis V. Lunev wrote:
>>>> nothing is discarded after module load. Though, I can be wrong. Could
>>>> you point me to the exact place?
>>> If __initdata is not discarded after module load then we should do it.
>>> There is no reason to waste __initdata RAM when the module is loaded.
>> Down at the bottom of sys_init_module we have:
>>
>> 	/* Drop initial reference. */
>> 	module_put(mod);
>> 	unwind_remove_table(mod->unwind_info, 1);
>>
>> 	module_free(mod, mod->module_init);
>> ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
>> 	mod->module_init = NULL;
>> 	mod->init_size = 0;
>> 	mod->init_text_size = 0;
>> 	mutex_unlock(&module_mutex);
>>
>> 	return 0;
>>
>> Which frees the memory for the .init sections.
> 
> Thanks for clarifying this Eric - should have looked myself..

clear :) I was wrong... Thank you for pointing this out.

will you mind against this?

--------------090406030502050409000403
Content-Type: text/plain;
 name="1.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="1.diff"

diff --git a/include/net/net_namespace.h b/include/net/net_namespace.h
index 5dd6d90..d136707 100644
--- a/include/net/net_namespace.h
+++ b/include/net/net_namespace.h
@@ -119,10 +119,14 @@ static inline struct net *maybe_get_net(struct net *net)
 #ifdef CONFIG_NET_NS
 #define __net_init
 #define __net_exit
-#define __net_initdata
 #else
 #define __net_init	__init
 #define __net_exit	__exit_refok
+#endif
+
+#if defined(CONFIG_NET_NS) || defined(MODULE)
+#define __net_initdata
+#else
 #define __net_initdata	__initdata
 #endif
 

--------------090406030502050409000403
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Containers mailing list
Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
https://lists.linux-foundation.org/mailman/listinfo/containers
--------------090406030502050409000403--
