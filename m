From: =?utf-8?Q?Bj=C3=B8rn_Mork?= <bjorn@mork.no>
Subject: Re: [PATCH 1/2] usbnet: allow status interrupt URB to always be active
Date: Sat, 05 Jan 2013 12:44:28 +0100
Message-ID: <87r4lzn9b7.fsf@nemi.mork.no>
References: <20110727141246.GC29616@orbit.nwl.cc>
	<2212516.GkG3xP33yG@linux-5eaq.site>
	<1357349193.19684.3.camel@dcbw.foobar.com>
	<3476529.YzSzbMTfeu@linux-5eaq.site>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Dan Williams <dcbw@redhat.com>,
	Elina Pasheva <epasheva@sierrawireless.com>,
	netdev@vger.kernel.org, linux-usb@vger.kernel.org,
	Rory Filer <rfiler@sierrawireless.com>,
	Phil Sutter <phil@nwl.cc>
To: Oliver Neukum <oliver@neukum.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from canardo.mork.no ([148.122.252.1]:60319 "EHLO canardo.mork.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754707Ab3AELok convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 5 Jan 2013 06:44:40 -0500
In-Reply-To: <3476529.YzSzbMTfeu@linux-5eaq.site> (Oliver Neukum's message of
	"Sat, 05 Jan 2013 12:01:55 +0100")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Oliver Neukum <oliver@neukum.org> writes:
> On Friday 04 January 2013 19:26:33 Dan Williams wrote:
>
>> I'd previously done a patch to handle this all in sierra_net, but th=
e
>> problem there is suspend/resume: without directly accessing the usbn=
et
>> structure's ->suspend_count member (icky!) sierra_net can't correctl=
y
>> kill/submit the URB itself.  So I went with a flag to usbnet that Si=
erra
>> can set.
>
> That is absolutely the right way to do it.

Yes.

Just a comment regarding the ->suspend_count: Are you absolutely sure
you need to look at that, Dan?  usbnet uses it to handle suspend/resume
for minidrivers with an unknown number of interfaces, without knowing
whether it is the control or data interface which is suspended or
resumed first.  By using the counter it can ensure that the correct
action is taken exactly once regardless of this.

The sierra_net minidriver has the advantage of knowing that there alway=
s
is only *one* USB interface being suspended and resumed.  So you don't
have to care about ->suspend_count.  Just do whatever you need to do on
suspend and resume.


Bj=C3=B8rn
