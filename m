From: Sander Eikelenboom <linux@eikelenboom.it>
Subject: Re: [Xen-devel] Xen-unstable Linux 3.14-rc3 and 3.13 Network troubles "bisected"
Date: Wed, 26 Mar 2014 18:33:04 +0100
Message-ID: <966386043.20140326183304@eikelenboom.it>
References: <1744594108.20140318162127@eikelenboom.it> <20140318160412.GB16807@zion.uk.xensource.com> <1701035622.20140318211402@eikelenboom.it> <722971844.20140318221859@eikelenboom.it> <1688396550.20140319001104@eikelenboom.it> <20140319113532.GD16807@zion.uk.xensource.com> <246793256.20140319220752@eikelenboom.it> <20140321164958.GA31766@zion.uk.xensource.com> <1334202265.20140321182727@eikelenboom.it> <1056661597.20140322192834@eikelenboom.it> <20140325151539.GG31766@zion.uk.xensource.com> <79975567.20140325162942@eikelenboom.it> <1972209744.20140326121116@eikelenboom.it> <9AAE0902D5BC7E449B7C8E4E778ABCD029AD94@AMSPEX01CL01.citrite.net> <1715463578.20140326162245@eikelenboom.it> <9AAE0902D5BC7E449B7C8E4E778ABCD029AFC1@AMSPEX01CL01.citrite.net> <799579453.20140326170641@eikelenboom.it>
 <9AAE0902D5BC7E449B7C8E4E778ABCD029B106@AMSPEX01CL01.citrite.net> <789809468.20140326175352@eikelenboom.it> <9AAE0902D5BC7E449B7C8E4E778ABCD029B277@AMSPEX01CL01.citrite.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Wei Liu <wei.liu2@citrix.com>, annie li <annie.li@oracle.com>,
	Zoltan Kiss <zoltan.kiss@citrix.com>,
	"xen-devel@lists.xen.org" <xen-devel@lists.xen.org>,
	Ian Campbell <Ian.Campbell@citrix.com>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Paul Durrant <Paul.Durrant@citrix.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <9AAE0902D5BC7E449B7C8E4E778ABCD029B277@AMSPEX01CL01.citrite.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Hi Paul,

Seems your last mail arrived in pretty bad shape (truncated) in my mailbox ..

--
Sander

Wednesday, March 26, 2014, 6:16:49 PM, you wrote:

>> -----Original Message-----
>> From: Sander Eikelenboom [mailto:linux@eikelenboom.it]
>> Sent: 26 March 2014 16:54
>> To: Paul Durrant
>> Cc: Wei Liu; annie li; Zoltan Kiss; xen-devel@lists.xen.org; Ian Campbell; linux-
>> kernel; netdev@vger.kernel.org
>> Subject: Re: [Xen-devel] Xen-unstable Linux 3.14-rc3 and 3.13 Network
>> troubles "bisected"
>> 
>> 
>> Wednesday, March 26, 2014, 5:25:21 PM, you wrote:
>> 
>> >> -----Original Message-----
>> >> From: Sander Eikelenboom [mailto:linux@eikelenboom.it]
>> >> Sent: 26 March 2014 16:07
>> >> To: Paul Durrant
>> >> Cc: Wei Liu; annie li; Zoltan Kiss; xen-devel@lists.xen.org; Ian Campbell;
>> linux-
>> >> kernel; netdev@vger.kernel.org
>> >> Subject: Re: [Xen-devel] Xen-unstable Linux 3.14-rc3 and 3.13 Network
>> >> troubles "bisected"
>> >>
>> >>
>> >> Wednesday, March 26, 2014, 4:50:30 PM, you wrote:
>> >>
>> >> >> -----Original Message-----
>> >> >> From: Sander Eikelenboom [mailto:linux@eikelenboom.it]
>> >> >> Sent: 26 March 2014 15:23
>> >> >> To: Paul Durrant
>> >> >> Cc: Wei Liu; annie li; Zoltan Kiss; xen-devel@lists.xen.org; Ian Campbell;
>> >> linux-
>> >> >> kernel; netdev@vger.kernel.org
>> >> >> Subject: Re: [Xen-devel] Xen-unstable Linux 3.14-rc3 and 3.13 Network
>> >> >> troubles "bisected"
>> >> >>
>> >> >>
>> >> >> Wednesday, March 26, 2014, 3:44:42 PM, you wrote:
>> >> >>
>> >> >> >> -----Original Message-----
>> >> >> >> From: Sander Eikelenboom [mailto:linux@eikelenboom.it]
>> >> >> >> Sent: 26 March 2014 11:11
>> >> >> >> To: Paul Durrant
>> >> >> >> Cc: Wei Liu; annie li; Zoltan Kiss; xen-devel@lists.xen.org; Ian
>> Campbell;
>> >> >> linux-
>> >> >> >> kernel; netdev@vger.kernel.org
>> >> >> >> Subject: Re: [Xen-devel] Xen-unstable Linux 3.14-rc3 and 3.13
>> Network
>> >> >> >> troubles "bisected"
>> >> >> >>
>> >> >> >> Paul,
>> >> >> >>
>> >> >> >> You have been awfully silent for this whole thread while this is a
>> >> >> regression
>> >> >> >> caused by a patch of you
>> >> >> >> (ca2f09f2b2c6c25047cfc545d057c4edfcfe561c as clearly stated much
>> >> earlier
>> >> >> in
>> >> >> >> this thread).
>> >> >> >>
>> >> >>
>> >> >> > Sorry, I've been distracted...
>> >> >>
>> >> >> >> The commit messages states:
>> >> >> >>     "net_rx_action() is the place where we could do with an accurate
>> >> >> >> predicition but,
>> >> >> >>     since that has proven tricky to calculate, a cheap worse-case (but
>> not
>> >> >> too
>> >> >> >> bad)
>> >> >> >>     estimate is all we really need since the only thing we *must*
>> prevent
>> >> is
>> >> >> >> xenvif_gop_skb()
>> >> >> >>     consuming more slots than are available."
>> >> >> >>
>> >> >> >> Your "worst-case" calculation stated in the commit message is
>> clearly
>> >> not
>> >> >> the
>> >> >> >> worst case,
>> >> >> >> since it doesn't take calls to "get_next_rx_buffer" into account
