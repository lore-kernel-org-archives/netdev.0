From: Mark Lord <lkml-gsilrlXbHYg@public.gmane.org>
Subject: Re: namespace support requires network modules to say "GPL"
Date: Sat, 01 Dec 2007 15:21:12 -0500
Message-ID: <4751C238.6010609@rtr.ca>
References: <m163zi9425.fsf@ebiederm.dsl.xmission.com>	<47515D39.9030900@rtr.ca>
	<20071201111736.297dd99a@freepuppy.rosehill>	<20071201192341.6750fbdb@the-village.bc.nu>	<20071201113815.5df0960a@freepuppy.rosehill>
	<m13aum5g1x.fsf@ebiederm.dsl.xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Tejun Heo <htejun-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, kay.sievers-tD+1rO4QERM@public.gmane.org,
        Greg KH <greg-U8xfFu+wG4EAvxtiuMwx3w@public.gmane.org>, Greg Kroah-Hartman <gregkh-l3A5Bk7waGM@public.gmane.org>,
        linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, cornelia.huck-tA70FqPdS9bQT0dZR+AlfA@public.gmane.org,
        Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
        stern-nwvwT67g6+6dFdvTe/nMLpVzexx5G7lz@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>,
        Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
        Stephen Hemminger <shemminger-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
        David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
        Alan Cox <alan-qBU/x9rampVanCEyBjwyrvXRex20P6io@public.gmane.org>,
        Herbert Xu <herbert-lOAM2aK0SrRLBo1qDEOMRrpzq4S04n8Q@public.gmane.org>
To: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <m13aum5g1x.fsf-T1Yj925okcoyDheHMi7gv2pdwda3JcWeAL8bYrjMMd8@public.gmane.org>
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

Eric W. Biederman wrote:
> Stephen Hemminger <shemminger-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org> writes:
> 
>> Actually, the whole mess would go away if the api for dev_get_by_XXXX hadn't
>> been changed in the namespace transition. IMHO the interface to
>> dev_get_by_name()
>> should not have added a namespace parameter, of the callers in the tree, only
>> two use a different namespace. So it would have been better to to introduce
>> dev_get_by_name_ns() with the extra parameter.
> 
> As a general rule if you are calling dev_get_by_name and taking an &init_net
> parameter that means you code has not yet been converted to actually support
> network namespaces.
> 
> Not everything can be safely changed at once so we take it by steps.  When
> the code fully supports network namespaces practically nothing will take
> an &init_net parameter.  The network namespace parameter will come in
> some form from userspace.  Either from current or from the network
> socket.
> 
> Except for boot time initialization I don't know of any cases using
> dev_get_by_XXXX that won't need to be modified before the network
> namespace work is complete.
> 
> I believe I mentioned that this getting the fully network namespace
> support was going to take a while and a bunch of patches at the
> outset.
> 
>> Can we get this resolved before 2.6.24 is released? Going back and forth
>> on API's is just needless frottage.
> 
> Sure.  We keep the updated dev_get_by_XXXX that takes a network
> namespace parameter.
..

And what should code be passing in when "# CONFIG_NET_NS is not set" ?
