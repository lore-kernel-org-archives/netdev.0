From: "Luis R. Rodriguez" <mcgrof@suse.com>
Subject: Re: net-PA Semi: Deletion of unnecessary checks before the function
 call "pci_dev_put"
Date: Tue, 2 Dec 2014 13:45:26 -0500
Message-ID: <CAB=NE6VUiWoiTe+uM=0NrhPx3fVDwXYaAKSZjzK3wT8sh7cazw@mail.gmail.com>
References: <5307CAA2.8060406@users.sourceforge.net> <alpine.DEB.2.02.1402212321410.2043@localhost6.localdomain6>
 <530A086E.8010901@users.sourceforge.net> <alpine.DEB.2.02.1402231635510.1985@localhost6.localdomain6>
 <530A72AA.3000601@users.sourceforge.net> <alpine.DEB.2.02.1402240658210.2090@localhost6.localdomain6>
 <530B5FB6.6010207@users.sourceforge.net> <alpine.DEB.2.10.1402241710370.2074@hadrien>
 <530C5E18.1020800@users.sourceforge.net> <alpine.DEB.2.10.1402251014170.2080@hadrien>
 <530CD2C4.4050903@users.sourceforge.net> <alpine.DEB.2.10.1402251840450.7035@hadrien>
 <530CF8FF.8080600@users.sourceforge.net> <alpine.DEB.2.02.1402252117150.2047@localhost6.localdomain6>
 <530DD06F.4090703@users.sourceforge.net> <alpine.DEB.2.02.1402262129250.2221@localhost6.localdomain6>
 <5317A59D.4@users.sourceforge.net> <547BC5AD.6090500@users.sourceforge.net>
 <1417465745.28610.0.camel@sipsolutions.net> <alpine.DEB.2.02.1412012134290.2076@localhost6.localdomain6>
 <1417539208.1841.1.camel@sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Julia Lawall <julia.lawall@lip6.fr>,
	SF Markus Elfring <elfring@users.sourceforge.net>,
	Lino Sanfilippo <LinoSanfilippo@gmx.de>,
	Olof Johansson <olof@lixom.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"backports@vger.kernel.org" <backports@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>,
	"kernel-janitors@vger.kernel.org" <kernel-janitors@vger.kernel.org>
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1417539208.1841.1.camel@sipsolutions.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Dec 2, 2014 at 11:53 AM, Johannes Berg
<johannes@sipsolutions.net> wrote:
> On Mon, 2014-12-01 at 21:34 +0100, Julia Lawall wrote:
>
>> > So this kind of evolution is no problem for the (automated) backports
>> > using the backports project - although it can be difficult to detect
>> > such a thing is needed.
>>
>> That is exactly the problem...
>
> I'm not convinced though that it should stop such progress in mainline.

I believe this case requires a bit more information explained as to
why it was explained. The "form" of change this patch has is of the
type that can crash systems if the NULL pointer check on the caller
implementation was only added later. We might be able to grammatically
check for this situation in the future if we had a white list / black
list / kernel revision where the NULL check was added but for now we
don't have that and as such care is just required on the developer in
consideration for backports.

It should be up to the maintainer to appreciate the gains of doing
something differently to make it easier for backporting. I obviously
think its a good thing to consider, its extra work though, so only if
the maintainer has some appreciation for backporting would this make
sense.

In this particular case I've reviewed Julia's concern and I've
determined that the patch is safe up to at least v2.6.12-rc2 (which is
where our git history begins on Linus' tree), this is because the
check for NULL has been there since then:

git show 1da177e drivers/pci/pci-driver.c

+void pci_dev_put(struct pci_dev *dev)
+{
+       if (dev)
+               put_device(&dev->dev);
+}

So this type of wide collateral evolution should not cause panics.
Because of this:

Acked-by: Luis R. Rodriguez <mcgrof@suse.com>

But note -- I still think its only good for us to vet these, if we
can't why not? If the maintainer doesn't give a shit that's different,
but if there are folks out there willing to help with vetting then
well, why not :)

PS. Including something like historical vetting as I did above on the
commit log should help folks.

 Luis
