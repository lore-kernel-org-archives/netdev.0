From: "Zhu Han" <schumi.han@gmail.com>
Subject: Re: [PATCH 4/4] [Net] Support accelerated network plugin
	modules
Date: Fri, 15 Jun 2007 14:03:05 -0400
Message-ID: <4e777ed10706151103w35ae4acv149d82aba0b59775@mail.gmail.com>
References: <1181904393.4121.55.camel@moonstone.uk.level5networks.com>
	<4e777ed10706150859r3b6e1617o3b31e5e24a30e6c9@mail.gmail.com>
	<1181924563.4121.94.camel@moonstone.uk.level5networks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, xen-devel@lists.xensource.com,
	herbert@gondor.apana.org.au
To: "Kieran Mansley" <kmansley@solarflare.com>
Return-path: <xen-devel-bounces@lists.xensource.com>
In-Reply-To: <1181924563.4121.94.camel@moonstone.uk.level5networks.com>
Content-Disposition: inline
List-Unsubscribe: <http://lists.xensource.com/cgi-bin/mailman/listinfo/xen-devel>,
	<mailto:xen-devel-request@lists.xensource.com?subject=unsubscribe>
List-Post: <mailto:xen-devel@lists.xensource.com>
List-Help: <mailto:xen-devel-request@lists.xensource.com?subject=help>
List-Subscribe: <http://lists.xensource.com/cgi-bin/mailman/listinfo/xen-devel>,
	<mailto:xen-devel-request@lists.xensource.com?subject=subscribe>
Sender: xen-devel-bounces@lists.xensource.com
Errors-To: xen-devel-bounces@lists.xensource.com
List-Id: netdev.vger.kernel.org

On 6/15/07, Kieran Mansley <kmansley@solarflare.com> wrote:
>
> The lock protects the use_count variable.  The use_count variable
> prevents the plugin module unloading while it is being used.  I couldn't
> just use the lock to prevent the module unloading as the hook function
> (i) might block (and holding a spin_lock would be rather antisocial)
> (ii) might call back into netfront and try to take the lock again, which
> would deadlock.
>

If the hook routine blocks on the other code path instead of tx/rx
path,  why not use a simple atomic reference count. When the reference
count reachs zero, free it. Considering you can synchronzie on tx/rx
path, the free will not happen under the critical code path. So the
uninitialize work could be done inside the free routine even if it
blocks.

>I think that RCU would only work in this situation if the hook functions
>didn't block,.

I agree.

>
> Kieran
>
>
>
>
>
>


-- 
best regards,
hanzhu
