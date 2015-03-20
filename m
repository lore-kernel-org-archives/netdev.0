From: Nicholas Mc Guire <der.herr@hofr.at>
Subject: Re: [PATCH RFC] wimax/i2400m: fixup completion handling for
	resetting a device
Date: Fri, 20 Mar 2015 08:47:05 +0100
Message-ID: <20150320074705.GB21852@opentech.at>
References: <1426585774-24204-1-git-send-email-hofrat@osadl.org> <55096FA1.9030908@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Nicholas Mc Guire <hofrat@osadl.org>,
	Inaky Perez-Gonzalez <inaky.perez-gonzalez@intel.com>,
	linux-wimax@intel.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <55096FA1.9030908@cogentembedded.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 18 Mar 2015, Sergei Shtylyov wrote:

> Hello.
>
> On 3/17/2015 12:49 PM, Nicholas Mc Guire wrote:
>
>> wait_for_completion_timeout return 0 (timeout) or >=1 (completion) so the check
>> for > 0 in the else branch is always true and can be dropped. The comment seems
>> misleading as it is always going to pass the result up.
>
>> The sync of the completion access with __i2400m_dev_reset_handle (which checks
>> for   if (i2400m->reset_ctx)   could race if i2400m_reset() returns negative so
>> the resetting of i2400m->reset_ctx == NULL is moved to the out: path.
>
>> As wait_for_completion_timeout returns unsigned long not int, an appropriately
>> named variable of type unsigned long is added and assignments fixed up.
>
>    Don't try to do several things in one patch.
>
normaly yes - this was marked as RFC and if I had split it up into
3 patches it would be hard to see how it fits together without
actually applying them.

The intent was to get feedback notably on moving i2400m->reset_ctx == NULL
and if dropping the (I think missleading) comment about negative return is ok

Should this be in seperate patches even as RFC ?
Once that is clarified it will go out as 3 patchs.

thx!
hofrat
