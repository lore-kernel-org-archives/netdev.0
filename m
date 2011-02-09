From: Chuck Lever <chuck.lever-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
Subject: Re: STMMAC driver: NFS Problem on 2.6.37
Date: Wed, 9 Feb 2011 16:26:16 -0500
Message-ID: <5CC01953-376D-46FC-99DA-C282332FA40F@oracle.com>
References: <4D2EC133.7010607@st.com> <2D04CF75-CA68-4BDC-99A3-FA1DD6113602@oracle.com> <4D2F4453.4040400@st.com> <4D301DD1.9070104@st.com> <593F2676-CA62-4D77-90AD-41F2FAF13EB6@oracle.com> <4D3EBA54.4020308@st.com> <EFFBD485-8B7E-44D1-A8D2-61E73BF42DF9@oracle.com> <20110209200129.GA6402@glaurung.lavos.net> <D031EAC4-68E9-4E56-8DB3-208B34C8DFD7@oracle.com> <20110209205855.GB6402@glaurung.lavos.net>
Mime-Version: 1.0 (Apple Message framework v1082)
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: deepaksi <deepak.sikri-qxv4g6HH51o@public.gmane.org>,
	Armando VISCONTI <armando.visconti-qxv4g6HH51o@public.gmane.org>,
	Trond Myklebust <Trond.Myklebust-HgOvQuBEEgTQT0dZR+AlfA@public.gmane.org>,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Linux NFS Mailing List <linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Shiraz HASHIM <shiraz.hashim-qxv4g6HH51o@public.gmane.org>,
	Viresh KUMAR <viresh.kumar-qxv4g6HH51o@public.gmane.org>,
	Peppe CAVALLARO <peppe.cavallaro-qxv4g6HH51o@public.gmane.org>,
	amitgoel <amit.goel-qxv4g6HH51o@public.gmane.org>
To: Brian Downing <bdowning-oU/tDdhfGLReoWH0uzbU5w@public.gmane.org>
Return-path: <linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20110209205855.GB6402-QEOkiq82tQWoLK6CJbI5/KxOck334EZe@public.gmane.org>
Sender: linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


On Feb 9, 2011, at 3:58 PM, Brian Downing wrote:

> On Wed, Feb 09, 2011 at 03:12:22PM -0500, Chuck Lever wrote:
>> Based on your console logs, I see that the working case uses UDP to
>> contact the server's mountd, but the failing case uses TCP.  You can
>> try explicitly specifying "proto=udp" to force the use of UDP, to test
>> this theory.
> 
> This does indeed make it work again for me, thanks!
> 
>> Meanwhile, the patch description explicitly states that the default
>> mount option settings have changed.  Does it make sense to change the
>> default behavior of NFSROOT mounts to use UDP again?  I don't see
>> another way to make this process more reliable across NIC
>> initialization.  If this is considered a regression, we can make a
>> patch for 2.6.38-rc and 2.6.37.
> 
> I only use nfsroot for development, so I don't have a terribly strong
> opinion.  I would point out though that the default u-boot parameters
> for nfsrooting a lot of boards will no longer work at this point, so if
> it's not patched to work again without specifying nfs options I think
> there should at least be a note in the documentation and possibly a
> "maybe try proto=udp?" console message on failure.
> 
> I assume it's not feasable to either wait until the chosen interface's
> link is ready before trying to mount nfsroot, or retrying TCP-based
> connections a little bit more aggressively/at all?

Our goal is to use the same mount logic for both normal user space mounts and for NFSROOT (that was the purpose of the patch series this particular patch comes from).  It's exceptionally difficult to add a special case for retrying TCP connections here, as that would change the behavior of user space mounts, which often want to fail quickly, and don't need to worry about NIC initialization.

Sounds like the right thing to do is restore the default UDP behavior.  I'll cook up a patch.

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com

--
To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
