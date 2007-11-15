From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH 2/2] move unneeded data to initdata section
Date: Thu, 15 Nov 2007 11:19:26 -0700
Message-ID: <m13av7xtg1.fsf@ebiederm.dsl.xmission.com>
References: <20071107120100.GA10185@iris.sw.ru>
	<m1abpfy3xz.fsf@ebiederm.dsl.xmission.com> <473C5ABC.5090204@sw.ru>
	<20071115151429.GC22825@uranus.ravnborg.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Denis V. Lunev" <den@sw.ru>, "Denis V. Lunev" <den@openvz.org>,
	davem@davemloft.net, containers@lists.osdl.org,
	netdev@vger.kernel.org, clg@fr.ibm.com, benjamin.thery@bull.net
To: Sam Ravnborg <sam@ravnborg.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ebiederm.dsl.xmission.com ([166.70.28.69]:45299 "EHLO
	ebiederm.dsl.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751718AbXKOSVk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Nov 2007 13:21:40 -0500
In-Reply-To: <20071115151429.GC22825@uranus.ravnborg.org> (Sam Ravnborg's
	message of "Thu, 15 Nov 2007 16:14:29 +0100")
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Sam Ravnborg <sam@ravnborg.org> writes:

> On Thu, Nov 15, 2007 at 05:42:04PM +0300, Denis V. Lunev wrote:
>> 
>> nothing is discarded after module load. Though, I can be wrong. Could
>> you point me to the exact place?
> If __initdata is not discarded after module load then we should do it.
> There is no reason to waste __initdata RAM when the module is loaded.

Down at the bottom of sys_init_module we have:

	/* Drop initial reference. */
	module_put(mod);
	unwind_remove_table(mod->unwind_info, 1);

	module_free(mod, mod->module_init);
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
	mod->module_init = NULL;
	mod->init_size = 0;
	mod->init_text_size = 0;
	mutex_unlock(&module_mutex);

	return 0;

Which frees the memory for the .init sections.

Eric
