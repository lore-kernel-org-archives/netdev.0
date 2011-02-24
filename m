From: Chuck Lever <chuck.lever-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
Subject: Re: STMMAC driver: NFS Problem on 2.6.37
Date: Thu, 24 Feb 2011 10:33:08 -0800
Message-ID: <CFD8EE5F-D6D4-4621-81F4-11CA4FD22F9F@oracle.com>
References: <2D04CF75-CA68-4BDC-99A3-FA1DD6113602@oracle.com> <4D2F4453.4040400@st.com> <4D301DD1.9070104@st.com> <593F2676-CA62-4D77-90AD-41F2FAF13EB6@oracle.com> <4D3EBA54.4020308@st.com> <EFFBD485-8B7E-44D1-A8D2-61E73BF42DF9@oracle.com> <20110209200129.GA6402@glaurung.lavos.net> <D031EAC4-68E9-4E56-8DB3-208B34C8DFD7@oracle.com> <20110209205855.GB6402@glaurung.lavos.net> <5CC01953-376D-46FC-99DA-C282332FA40F@oracle.com> <20110224133627.GO920@DLHLAP0379>
Mime-Version: 1.0 (Apple Message framework v1082)
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: Brian Downing <bdowning-oU/tDdhfGLReoWH0uzbU5w@public.gmane.org>,
	Deepak SIKRI <deepak.sikri-qxv4g6HH51o@public.gmane.org>,
	Armando VISCONTI <armando.visconti-qxv4g6HH51o@public.gmane.org>,
	Trond Myklebust <Trond.Myklebust-HgOvQuBEEgTQT0dZR+AlfA@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Linux NFS Mailing List <linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Viresh KUMAR <viresh.kumar-qxv4g6HH51o@public.gmane.org>,
	Peppe CAVALLARO <peppe.cavallaro-qxv4g6HH51o@public.gmane.org>,
	amitgoel <amit.goel-qxv4g6HH51o@public.gmane.org>
To: Shiraz Hashim <shiraz.hashim-qxv4g6HH51o@public.gmane.org>
Return-path: <linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20110224133627.GO920@DLHLAP0379>
Sender: linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


On Feb 24, 2011, at 5:36 AM, Shiraz Hashim wrote:

> On Thu, Feb 10, 2011 at 05:26:16AM +0800, Chuck Lever wrote:
>> 
>> On Feb 9, 2011, at 3:58 PM, Brian Downing wrote:
>> 
>>> On Wed, Feb 09, 2011 at 03:12:22PM -0500, Chuck Lever wrote:
>>>> Based on your console logs, I see that the working case uses UDP to
>>>> contact the server's mountd, but the failing case uses TCP.  You can
>>>> try explicitly specifying "proto=udp" to force the use of UDP, to test
>>>> this theory.
>>> 
>>> This does indeed make it work again for me, thanks!
>>> 
>>>> Meanwhile, the patch description explicitly states that the default
>>>> mount option settings have changed.  Does it make sense to change the
>>>> default behavior of NFSROOT mounts to use UDP again?  I don't see
>>>> another way to make this process more reliable across NIC
>>>> initialization.  If this is considered a regression, we can make a
>>>> patch for 2.6.38-rc and 2.6.37.
>>> 
>>> I only use nfsroot for development, so I don't have a terribly strong
>>> opinion.  I would point out though that the default u-boot parameters
>>> for nfsrooting a lot of boards will no longer work at this point, so if
>>> it's not patched to work again without specifying nfs options I think
>>> there should at least be a note in the documentation and possibly a
>>> "maybe try proto=udp?" console message on failure.
>>> 
>>> I assume it's not feasable to either wait until the chosen interface's
>>> link is ready before trying to mount nfsroot, or retrying TCP-based
>>> connections a little bit more aggressively/at all?
>> 
>> Our goal is to use the same mount logic for both normal user
>> space mounts and for NFSROOT (that was the purpose of the patch
>> series this particular patch comes from).  It's
>> exceptionally difficult to add a special case for retrying TCP
>> connections here, as that would change the behavior of user
>> space mounts, which often want to fail quickly, and don't need
>> to worry about NIC initialization.
>> 
>> Sounds like the right thing to do is restore the default UDP behavior.  I'll cook up a patch.
> 
> Is there some patch available for this now.

Yes, it was posted a couple of weeks ago (sorry, I don't have an exact reference).  I will ping Trond again about getting this upstream.

> There is one more observation (on 2.6.37), when I pass
> nfsroot=$(ip):$(rootpath),udp , then it works fine.
> If I pass proto=udp then it doesn't work. Is there any difference
> between the two methods ?

It may be that proto=udp has an effect only on the transport used for NFS requests, but not for the MNT request.  "udp" means "proto=udp,mountproto=udp."

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com



--
To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
