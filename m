From: John Ronciak <john.ronciak@gmail.com>
Subject: Re: My vote against eepro* removal
Date: Fri, 20 Jan 2006 18:01:53 -0800
Message-ID: <56a8daef0601201801s6f8c3b79xcc06aaacc430309d@mail.gmail.com>
References: <AAD6DA242BC63C488511C611BD51F367323324@MAILIT.keba.co.at>
	 <20060120095548.GA16000@2ka.mipt.ru>
	 <1137804050.3241.32.camel@mindpipe>
	 <56a8daef0601201719t448a6177lfebabe3ca38a00c7@mail.gmail.com>
	 <1137807048.3241.58.camel@mindpipe>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: Evgeniy Polyakov <johnpol@2ka.mipt.ru>,
	kus Kusche Klaus <kus@keba.com>,
	Adrian Bunk <bunk@stusta.de>, linux-kernel@vger.kernel.org,
	john.ronciak@intel.com, ganesh.venkatesan@intel.com,
	jesse.brandeburg@intel.com, netdev@vger.kernel.org,
	Steven Rostedt <rostedt@goodmis.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1030330AbWAUCBz@vger.kernel.org>
To: Lee Revell <rlrevell@joe-job.com>
In-Reply-To: <1137807048.3241.58.camel@mindpipe>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 1/20/06, Lee Revell <rlrevell@joe-job.com> wrote:
>
> Why don't these cause excessive scheduling delays in eepro100 then?
> Can't we just copy the eepro100 behavior?
Reports still float around from time to time about hangs with the
eepro100 which go away when the e100 driver is used.  We don't
maintain the eepro100 driver so I can't tell you much about it other
than the reports we get sometimes.

There is a timer routine in the eepro100 driver which does the check
for link as well as a check for on of the hang conditions (with
work-around).  It does the check for link in a different way than
e100.  e100 uses mii call where eepro100 does it manually.  Another
difference is that eepro100 doesn't get stats unless called by the
system.  It's not in the timer routine at all.

Can we try a couple of things? 1) just comment out all the check for
link code in the e100 driver and give that a try and 2) just comment
out the update stats call and see if that works.  These seem to be the
differences and we need to know which one is causing the problem.


--
Cheers,
John
