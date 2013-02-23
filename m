From: Paul Moore <pmoore@redhat.com>
Subject: Re: AF_VSOCK and the LSMs
Date: Fri, 22 Feb 2013 19:45:54 -0500
Message-ID: <1968537.V0Fsdryuo8@sifl>
References: <1803195.0cVPJuGAEx@sifl> <5127F874.1050907@schaufler-ca.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: netdev@vger.kernel.org, linux-security-module@vger.kernel.org,
	selinux@tycho.nsa.gov, Andy King <acking@vmware.com>,
	Gerd Hoffmann <kraxel@redhat.com>,
	Eric Paris <eparis@redhat.com>
To: Casey Schaufler <casey@schaufler-ca.com>
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <5127F874.1050907@schaufler-ca.com>
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Friday, February 22, 2013 03:00:04 PM Casey Schaufler wrote:
> Please add an LSM blob. Please do not use a secid. I am currently
> battling with secids in my efforts for multiple LSM support.
>
> ...
> 
> I am going to be able to deal with secids for AF_INET only because
> SELinux prefers XFRM, Smack requires CIPSO, and AppArmor is going to
> be willing to have networking be optional.

"prefers"?  Really Casey, did you think I would let you get away with that 
statement?  What a LSM "prefers" is really not relevant to the stacking 
effort, what a LSM _supports_ is what matters.

SELinux _supports_ NetLabel (CIPSO, etc.), XFRM (labeled IPsec), and secmark.

Smack _supports_ NetLabel (CIPSO).

AppArmor and TOMOYO don't really do any of the forms of labeled networking 
that are relevant for this discussion.  If you are going to do stacking with 
LSMs that conflict when it comes to what they _support_, not what they 
_prefer_, with labeled networking then you are either going to have to either:

1. Selectively remove support from all but one of the LSMs. (ungh ...)
2. Convince netdev to give you a blob in the sk_buff. (the pigs are flying!)
3. Work some sub-system dependent magic.

If you want to try option #3 I think we might be able to do something with 
NetLabel to support multiple LSMs as the label abstraction stuff should 
theoretically make this possible; although the NetLabel cache will need some 
work.  Labeled IPsec is likely out due to the way it was designed unless you 
want to attempt to negotiate two labels during the IKE exchange (yuck).  I 
think we can also rule out secmark as multi-LSM enabled due to the limitations 
on a 32 bit integer.

If you want to talk about this further let me know - I think we've talked 
about this at the past two security summits - but don't attempt to gloss over 
details with this "prefers" crap.

> If you have two LSMs that use secids you are never going to have a
> rational way to get the information for both into one secid.

Exactly, I don't disagree which is why I've always said that networking was 
going to be a major problem for the stacked LSM effort.  Unfortunately it 
sounds like you haven't yet made any serious effort into resolving that 
problem other than saying "don't do that".

Now, circling back to the issue of secid/blob in the AF_VSOCK/VMCI context ... 
based on Andy's email I think I'm still missing some critical bit of 
understanding regarding how VMCI is used so let's punt on this for a moment; 
however, your preference for a blob is noted (you also remember that I prefer 
blobs when they make sense, reference a lot of our earlier discussions).

-- 
paul moore
security and virtualization @ redhat

