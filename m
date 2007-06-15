From: Keir Fraser <Keir.Fraser@cl.cam.ac.uk>
Subject: Re: [PATCH 0/4] [Net] Support accelerated network
	plugin modules
Date: Fri, 15 Jun 2007 12:26:03 +0100
Message-ID: <C29835DB.931B%Keir.Fraser@cl.cam.ac.uk>
References: <1181904378.4121.51.camel@moonstone.uk.level5networks.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, herbert@gondor.apana.org.au
To: Kieran Mansley <kmansley@solarflare.com>, <xen-devel@lists.xensource.com>
Return-path: <xen-devel-bounces@lists.xensource.com>
In-Reply-To: <1181904378.4121.51.camel@moonstone.uk.level5networks.com>
List-Unsubscribe: <http://lists.xensource.com/cgi-bin/mailman/listinfo/xen-devel>,
	<mailto:xen-devel-request@lists.xensource.com?subject=unsubscribe>
List-Post: <mailto:xen-devel@lists.xensource.com>
List-Help: <mailto:xen-devel-request@lists.xensource.com?subject=help>
List-Subscribe: <http://lists.xensource.com/cgi-bin/mailman/listinfo/xen-devel>,
	<mailto:xen-devel-request@lists.xensource.com?subject=subscribe>
Sender: xen-devel-bounces@lists.xensource.com
Errors-To: xen-devel-bounces@lists.xensource.com
List-Id: netdev.vger.kernel.org

On 15/6/07 11:46, "Kieran Mansley" <kmansley@solarflare.com> wrote:

> This is a repost of some earlier patches to the xen-devel mailing list,
> with a number of changes thanks to some useful suggestions from others.

The coding style needs fixing in various ways.

Hard tabs need to be used, no spaces inside brackets, but should include
spaces between if/while/for and bracket, and bracket and brace:
    if (foo) {
Not
    if( foo ){
    if(foo ) {
Or various other possibilities.

No use of the following please:
If (foo) return 1; else return 0;
Is clearer as:
Return foo;

There's a (good) idiom for error handling in Linux:
If (!error) {
    page of code;
} else {
    oh no, error, print and return;
}
Should be changed to:
If (error) {
    handle error, bail if necessary
}
Page of code, no longer indented by error check;

Apart from the various coding style bits, accelerator_probe_vifs_on_load()
walks the vif_states list with no lock held. Is this safe against the list
changing?

 -- Keir
