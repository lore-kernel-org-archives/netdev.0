From: "Bryan Donlan" <bdonlan@gmail.com>
Subject: Re: RFC: Network privilege separation.
Date: Mon, 12 Jan 2009 14:09:26 -0500
Message-ID: <3e8340490901121109w2569a820g2e979367fcca886b@mail.gmail.com>
References: <1231307334-9542-1-git-send-email-michael@laptop.org>
	 <87mye2yg8a.fsf@basil.nowhere.org>
	 <20090108023111.GJ3164@didacte.laptop.org>
	 <20090108104305.7b271053@lxorguk.ukuu.org.uk>
	 <12821.1231785850@turing-police.cc.vt.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "Alan Cox" <alan@lxorguk.ukuu.org.uk>,
	"Michael Stone" <michael@laptop.org>,
	"Andi Kleen" <andi@firstfloor.org>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: Valdis.Kletnieks@vt.edu
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1755331AbZALTJ6@vger.kernel.org>
In-Reply-To: <12821.1231785850@turing-police.cc.vt.edu>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Jan 12, 2009 at 1:44 PM,  <Valdis.Kletnieks@vt.edu> wrote:
> On Thu, 08 Jan 2009 10:43:05 GMT, Alan Cox said:
>
>> If you have the same uid then you can just use ptrace to drive another
>> task with that uid to do the creations for you. Chances are you can also
>> attack shared executable files (eg that uids .bashrc)
>>
>> That to me says controlling network access is only useful as part of a
>> more fine grained and general purpose interface. We already have that
>> interface in the form of things like SELinux. We already have systems
>> actively using it to control stuff like which ports are accessed by some
>> services.
>
> Yes, the network access part *is* something that should be part of a more
> general interface.  Having said that, we currently are lacking a way for a
> *general user* program to say "I'm all set up, and would like to disavow any
> other further resource access (except maybe r/o access as "other" to file
> systems)".
>
> It's pretty easy for stuff running as root to play setuid()/capability() games
> to throw away access rights.  It's damned hard for mortal users to do it.

Would this be something covered by namespaces? Eg, once you're done
with setup, clone into a new network and UID namespace. Now you have
no network interfaces, so you shouldn't be able to make any new
connections, and you won't be able to access any files except those
with 'other' access rights, right?
