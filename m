From: Rafal Ozieblo <rafalo@cadence.com>
Subject: RE: [PATCH net-next v2] macb: Common code to enable ptp support for
 MACB/GEM
Date: Fri, 27 Jan 2017 11:06:33 +0000
Message-ID: <BN3PR07MB2516525EBCC11BE7E5AC3ADBC9760@BN3PR07MB2516.namprd07.prod.outlook.com>
References: <1484841375-11420-1-git-send-email-andrei.pistirica@microchip.com>
 <BN3PR07MB25160FCBCF19918C495F43B4C9770@BN3PR07MB2516.namprd07.prod.outlook.com>
 <CAFcVECLuWM65zXJWtMcwijZ1ZbtH0pvKnTUR=SJagPGHEr9amg@mail.gmail.com>
 <BN3PR07MB25163747E1520E4CE1C6164FC9760@BN3PR07MB2516.namprd07.prod.outlook.com>
 <779c1540-f4da-90ee-1fa1-c94339a892aa@atmel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: "tbultel@pixelsurmer.com" <tbultel@pixelsurmer.com>,
 "boris.brezillon@free-electrons.com" <boris.brezillon@free-electrons.com>,
 "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
 "alexandre.belloni@free-electrons.com" <alexandre.belloni@free-electrons.com>,
 "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
 "richardcochran@gmail.com" <richardcochran@gmail.com>,
 Andrei Pistirica <andrei.pistirica@microchip.com>,
 "michals@xilinx.com" <michals@xilinx.com>,
 "anirudh@xilinx.com" <anirudh@xilinx.com>,
 "punnaia@xilinx.com" <punnaia@xilinx.com>,
 "harini.katakam@xilinx.com" <harini.katakam@xilinx.com>,
 "davem@davemloft.net" <davem@davemloft.net>,
 "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>
To: Nicolas Ferre <nicolas.ferre@atmel.com>, Harini Katakam
 <harinikatakamlinux@gmail.com>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <779c1540-f4da-90ee-1fa1-c94339a892aa@atmel.com>
Content-Language: en-US
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: "linux-arm-kernel" <linux-arm-kernel-bounces@lists.infradead.org>
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

Pi0tLS0tT3JpZ2luYWwgTWVzc2FnZS0tLS0tDQo+RnJvbTogTmljb2xhcyBGZXJyZSBbbWFpbHRv
Om5pY29sYXMuZmVycmVAYXRtZWwuY29tXSANCj5TZW50OiAyNyBzdHljem5pYSAyMDE3IDExOjI4
DQo+U3ViamVjdDogUmU6IFtQQVRDSCBuZXQtbmV4dCB2Ml0gbWFjYjogQ29tbW9uIGNvZGUgdG8g
ZW5hYmxlIHB0cCBzdXBwb3J0IGZvciBNQUNCL0dFTQ0KPg0KPkxlIDI3LzAxLzIwMTcgw6AgMTE6
MjYsIFJhZmFsIE96aWVibG8gYSDDqWNyaXQgOg0KPj4+IC0tLS0tT3JpZ2luYWwgTWVzc2FnZS0t
LS0tDQo+Pj4gRnJvbTogSGFyaW5pIEthdGFrYW0gW21haWx0bzpoYXJpbmlrYXRha2FtbGludXhA
Z21haWwuY29tXSANCj4+PiBTZW50OiAyNyBzdHljem5pYSAyMDE3IDA2OjQzDQo+Pj4gU3ViamVj
dDogUmU6IFtQQVRDSCBuZXQtbmV4dCB2Ml0gbWFjYjogQ29tbW9uIGNvZGUgdG8gZW5hYmxlIHB0
cCBzdXBwb3J0IGZvciBNQUNCL0dFTQ0KPj4+DQo+Pj4gSGkgUmFmYWwsDQo+Pj4NCj4+PiBPbiBU
aHUsIEphbiAyNiwgMjAxNyBhdCA4OjQ1IFBNLCBSYWZhbCBPemllYmxvIDxyYWZhbG9AY2FkZW5j
ZS5jb20+IHdyb3RlOg0KPj4+Pj4gLS0tLS1PcmlnaW5hbCBNZXNzYWdlLS0tLS0NCj4+Pj4+IEZy
b206IEFuZHJlaSBQaXN0aXJpY2EgW21haWx0bzphbmRyZWkucGlzdGlyaWNhQG1pY3JvY2hpcC5j
b21dDQo+Pj4+PiBTZW50OiAxOSBzdHljem5pYSAyMDE3IDE2OjU2DQo+Pj4+PiBTdWJqZWN0OiBb
UEFUQ0ggbmV0LW5leHQgdjJdIG1hY2I6IENvbW1vbiBjb2RlIHRvIGVuYWJsZSBwdHAgc3VwcG9y
dCBmb3IgTUFDQi9HRU0NCj4+Pj4+DQo+Pj4+Pg0KPj4+Pj4gK3N0YXRpYyBpbmxpbmUgYm9vbCBn
ZW1faGFzX3B0cChzdHJ1Y3QgbWFjYiAqYnApDQo+Pj4+PiArew0KPj4+Pj4gKyAgICAgcmV0dXJu
ICEhKGJwLT5jYXBzICYgTUFDQl9DQVBTX0dFTV9IQVNfUFRQKTsNCj4+Pj4+ICt9DQo+Pj4+IFdo
eSBkb24ndCB5b3UgdXNlIGhhcmR3YXJlIGNhcGFiaWxpdGllcyBoZXJlPyBXb3VsZCBpdCBiZSBi
ZXR0ZXIgdG8gcmVhZCBpdCBmcm9tIGhhcmR3YXJlIGluc3RlYWQgYWRkaW5nIGl0IHRvIG1hbnkg
Y29uZmlndXJhdGlvbj8NCj4+Pg0KPj4+IElmIHlvdSBhcmUgcmVmZXJyaW5nIHRvIFRTVSBiaXQg
aW4gRENGRzUsIHRoZW4gd2Ugd2lsbCBiZSByZWx5aW5nIG9uDQo+Pj4gQ2FkZW5jZSBJUCdzIGlu
Zm9ybWF0aW9uIGlycmVzcGVjdGl2ZSBvZiB0aGUgU29DIGNhcGFiaWxpdHkNCj4+PiBhbmQgd2hl
dGhlciB0aGUgUFRQIHN1cHBvcnQgd2FzIGFkZXF1YXRlLg0KPj4+IEkgdGhpbmsgdGhlIGNhcGFi
aWxpdHkgYXBwcm9hY2ggZ2l2ZXMgYmV0dGVyIGNvbnRyb2wgYW5kDQo+Pj4gaXQgaXMgbm90IHJl
YWxseSBtdWNoIHRvIGFkZC4NCj4+Pg0KPj4+IFJlZ2FyZHMsDQo+Pj4gSGFyaW5pDQo+Pj4NCj4+
IFllcywgSSdtIHJlZmVycmluZyB0byBUU1UgYml0Lg0KPj4gV2hhdCBpZiBTb0MgY29udGFpbnMg
bXVsdGlwbGUgQ2FkZW5jZSBHRU1zLCBzb21lIHdpdGggUFRQIHN1cHBvcnQgYW5kIG90aGVycyB3
aXRob3V0Pw0KPg0KPlNpbXBseSBkZWZpbmUgZGlmZmVyZW50IERUIGNvbXBhdGliaWxpdHkgc3Ry
aW5ncyBhbmQgd2UncmUgZ29vZC4NCg0KV2hhdCB3aXRoIEdFTSBvbiBQQ0kgPyBUaGVyZSBpcyBu
byBEVC4NCg0KPj4gUmVsZXZhbnQgd2lsbCBiZSBjaGVja2luZyBib3RoLCBoYXJkd2FyZSBjYXBh
YmlsaXRpZXMgYW5kIFNvQyBjYXBhYmlsaXRpZXMgZnJvbSAiY2FwcyIgZmllbGQuDQo+PiANCj4N
Cj4NCj4tLSANCj5OaWNvbGFzIEZlcnJlDQo+DQpfX19fX19fX19fX19fX19fX19fX19fX19fX19f
X19fX19fX19fX19fX19fX19fXwpsaW51eC1hcm0ta2VybmVsIG1haWxpbmcgbGlzdApsaW51eC1h
cm0ta2VybmVsQGxpc3RzLmluZnJhZGVhZC5vcmcKaHR0cDovL2xpc3RzLmluZnJhZGVhZC5vcmcv
bWFpbG1hbi9saXN0aW5mby9saW51eC1hcm0ta2VybmVsCg==
