From: Bjorn Helgaas <bhelgaas@google.com>
Subject: Re: [PATCH] phy: fix compiler array bounds warning on settings[]
Date: Wed, 5 Mar 2014 07:54:53 -0700
Message-ID: <CAErSpo5Pb2bABmnQZ04KRqjU=38=Pcr2OQv8hUJd_hv69QVc-A@mail.gmail.com>
References: <20140305003544.23016.55079.stgit@bhelgaas-glaptop.roam.corp.google.com>
 <063D6719AE5E284EB5DD2968C1650D6D0F6D1440@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: David Laight <David.Laight@aculab.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6D0F6D1440@AcuExch.aculab.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Mar 5, 2014 at 2:10 AM, David Laight <David.Laight@aculab.com> wrote:
> From: Bjorn Helgaas
>> With -Werror=array-bounds, gcc v4.7.x warns that in phy_find_valid(), the
>> settings[] "array subscript is above array bounds", I think because idx is
>> a signed integer and if the caller supplied idx < 0, we pass the guard but
>> still reference out of bounds.
>
> Not rejecting the patch but...
>
> Just indexing an array with 'int' shouldn't cause this warning,
> so somewhere a caller must actually be passing an idx < 0.
>
> While changing the type to unsigned will make the comparison
> against the array bound reject the -1, I suspect that the
> specific call path didn't really intend passing a hard-coded -1.
>
> It might be worth trying to locate the call site that passes -1.

I agree 100%.  If that's the case, we definitely should find that
caller rather than apply this patch.  I'll look more today.

Bjorn
